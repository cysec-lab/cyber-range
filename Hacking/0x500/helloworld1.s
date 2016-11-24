BITS 32             ; nasmに対してこれが32ビットコードであることを伝える

  call mark_below   ; 文字列の次に格納されている命令を呼び出す
  db "Hello, world!", 0x0a, 0x0d  ; 復帰改行を含む文字列

mark_below:
; ssize_t write(int fd, const void *buf, size_t count);
  pop ecx           ; 戻りアドレス（実は文字列へのポインタ）をecxにポップする
  mov eax, 4        ; システムコール番号を設定
  mov ebx, 1        ; 標準出力のファイル記述子
  mov edx, 15       ; 文字列の長さ
  int 0x80          ; システムコールの呼び出し： write(1, string, 14)

; void _exit(int status);
  mov eax, 1        ; exit()のシステムコール番号
  mov ebx, 0        ; ステータス = 0   
  int 0x80          ; システムコールの呼び出し：  exit(0)
