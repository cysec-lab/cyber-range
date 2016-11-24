section .data       ; データセグメント
msg     db      "Hello, world!", 0x0a   ; 文字列と改行文字

section .text       ; テキストセグメント
global _start       ; ELFとリンクを行う際のデフォルトエントリポイント

_start:
  ; SYSCALL: write(1, msg, 14) 
  mov eax, 4        ; 4をeaxに設定する（#4はwriteに相当するシステムコール）
  mov ebx, 1        ; 1をebxに設定する（1は標準出力に該当）
  mov ecx, msg      ; 文字列のアドレスをecxに設定する
  mov edx, 14       ; 14をedxに設定する（14バイトの文字列を出力するため）
  int 0x80          ; システムコールを行うためにカーネルを呼び出す

  ; SYSCALL: exit(0)
  mov eax, 1        ; 1をeaxに設定する（#1はexitに相当するシステムコール）
  mov ebx, 0        ; 正常終了する
  int 0x80          ; システムコールを実行する
