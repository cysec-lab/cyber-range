BITS 32             ; nasmに対してこれが32ビットコードであることを伝える

jmp short one       ; 終端部にあるcall命令に分岐する

two:
; ssize_t write(int fd, const void *buf, size_t count);
  pop ecx           ; 戻りアドレス（実は文字列へのポインタ）をecxにポップする
  xor eax, eax      ; eaxレジスタをゼロクリアする
  mov al, 4         ; システムコール番号4をeaxの下位バイトに設定
  xor ebx, ebx      ; ebxをゼロクリアする
  inc ebx           ; ebxをインクリメントして1（標準出力のファイル記述子）にする
  xor edx, edx
  mov dl, 15        ; 文字列の長さ
  int 0x80          ; システムコールの呼び出し： write(1, string, 14)

; void _exit(int status);
  mov al, 1        ; exit()のシステムコール番号（上位3バイトはまだゼロのままである）
  dec ebx          ; ステータスの0を表現するためにebxの値をデクリメントして0にする
  int 0x80         ; システムコールの呼び出し：  exit(0)

one:
  call two   ; nullバイトを避けるための後方分岐
  db "Hello, world!", 0x0a, 0x0d  ; 復帰改行を含む文字列
