#include <stdio.h> 
#include <stdlib.h> 
#include <string.h>

void *errorchecked_malloc(unsigned int); // errorchecked_malloc()の関数プロトタイプ

int main(int argc, char *argv[]) { 
   char *char_ptr;  // 文字（char）へのポインタ
   int *int_ptr;    // 整数（int）へのポインタ
   int mem_size;

   if (argc < 2)     // コマンドライン引数が与えられていない場合、
      mem_size = 50; // デフォルト値として50を使用する。
   else 
      mem_size = atoi(argv[1]);

   printf("\t[+]ヒープセグメントから%dバイトのメモリを割り当て、先頭アドレスをchar_ptrに代入します。\n", mem_size);
   char_ptr = (char *) errorchecked_malloc(mem_size); // ヒープメモリを割り当てる

   strcpy(char_ptr, "KOREHA HEAP NI COPY SAREMASU"); 
   printf("char_ptr (%p) --> '%s'\n", char_ptr, char_ptr); 
   printf("\t[+]ヒープセグメントから12バイトのメモリを割り当て、先頭アドレスをint_ptrに代入します。\n"); 
   int_ptr = (int *) errorchecked_malloc(12); // もう一度ヒープメモリを割り当てる

   *int_ptr = 31337; // int_ptrが指しているメモリに31337を格納する
   printf("int_ptr (%p) --> %d\n", int_ptr, *int_ptr);

   printf("\t[-]char_ptrが指しているヒープメモリを解放します。\n"); 
   free(char_ptr); // ヒープメモリの解放

   printf("\t[+]ヒープセグメントから再び15バイトのメモリを割り当て、先頭アドレスをchar_ptrに代入します。\n"); 
   char_ptr = (char *) errorchecked_malloc(15); // ヒープメモリを割り当てる

   strcpy(char_ptr, "NEW MEMORY");
   printf("char_ptr (%p) --> '%s'\n", char_ptr, char_ptr);

   printf("\t[-]int_ptrのヒープメモリを解放します。\n"); 
   free(int_ptr); // ヒープメモリの解放
   printf("\t[-]char_ptrのヒープメモリを解放します。\n"); 
   free(char_ptr); // ヒープメモリの別ブロックを解放
}

void *errorchecked_malloc(unsigned int size) { // エラー判定付きmalloc()関数
   void *ptr;
   ptr = malloc(size); 
   if(ptr == NULL) {
      fprintf(stderr, "エラー： ヒープメモリの割り当てに失敗しました。\n"); 
      exit(-1);
   }
   return ptr;
}
