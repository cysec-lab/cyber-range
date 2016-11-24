#include <stdio.h>

int main() { 
   int i;

   char char_array[5] = {'a', 'b', 'c', 'd', 'e'}; 
   int int_array[5] = {1, 2, 3, 4, 5};

   char *char_pointer; 
   int *int_pointer;

   char_pointer = int_array; // char_pointerとint_pointerが整合性のない
   int_pointer = char_array; // データ型のアドレスを指し示すようにする。

   for(i=0; i < 5; i++) { // int_pointerを繰り返し用いて整数の配列要素を取得
      printf("[整数へのポインタ]は%pを指しており、その内容は'%c'です。\n",
            int_pointer, *int_pointer); 
      int_pointer = int_pointer + 1;
   } 

   for(i=0; i < 5; i++) { // char_pointerを繰り返し用いて文字の配列要素を取得
      printf("[文字へのポインタ]は%pを指しており、その内容は%dです。\n", 
            char_pointer, *char_pointer);
      char_pointer = char_pointer + 1;
   }
}
