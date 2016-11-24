#include <stdio.h>

int main() { 
   int i;

   char char_array[5] = {'a', 'b', 'c', 'd', 'e'}; 
   int int_array[5] = {1, 2, 3, 4, 5};

   char *char_pointer; 
   int *int_pointer;

   char_pointer = (char *) int_array; // ポインタのデータ型にキャストする
   int_pointer = (int *) char_array; // （コンパイラの警告を抑止するため）

   for(i=0; i < 5; i++) { // int_pointerを繰り返し用いて整数の配列要素を取得
      printf("[整数へのポインタ]は%pを指しており、その内容は'%c'です。\n",
            int_pointer, *int_pointer);
      int_pointer = (int *) ((char *) int_pointer + 1);
   }

   for(i=0; i < 5; i++) { // char_pointerを繰り返し用いて文字の配列要素を取得
      printf("[文字への配列]は%pを指しており、その内容は%dです。\n",
            char_pointer, *char_pointer);
      char_pointer = (char *) ((int *) char_pointer + 1);
   }
}
