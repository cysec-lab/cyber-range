// エラーメッセージを表示して終了する関数
void fatal(char *message) {
   char error_message[100];

   strcpy(error_message, "[!!] 致命的なエラー：");
   strncat(error_message, message, 83); 
   perror(error_message); 
   exit(-1);
}

// malloc()とエラー判定をセットにした関数
void *ec_malloc(unsigned int size) {
   void *ptr; 
   ptr = malloc(size); 
   if(ptr == NULL)
      fatal("ec_malloc()内でメモリ割り当てに失敗しました。"); 
   return ptr;
}
