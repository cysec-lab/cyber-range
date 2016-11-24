#include <stdio.h>

int main() { 
   int i;

   char char_array[5] = {'a', 'b', 'c', 'd', 'e'}; 
   int int_array[5] = {1, 2, 3, 4, 5};

   void *void_pointer;

   void_pointer = (void *) char_array;

   for(i=0; i < 5; i++) { // void_pointerを繰り返し用いて文字の配列要素を取得
      printf("[文字へのポインタ]は%pを指しており、その内容は'%c'です。\n",
            void_pointer, *((char *) void_pointer)); 
      void_pointer = (void *) ((char *) void_pointer + 1);
   }

   void_pointer = (void *) int_array;

   for(i=0; i < 5; i++) { // void_pointerを繰り返し用いて整数の配列要素を取得
      printf("[整数へのポインタ]は%pを指しており、その内容は%dです。\n",
            void_pointer, *((int *) void_pointer)); 
      void_pointer = (void *) ((int *) void_pointer + 1);
   }
}
