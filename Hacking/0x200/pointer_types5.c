#include <stdio.h>

int main() { 
   int i;

   char char_array[5] = {'a', 'b', 'c', 'd', 'e'}; 
   int int_array[5] = {1, 2, 3, 4, 5};

   unsigned int hacky_nonpointer;

   hacky_nonpointer = (unsigned int) char_array;

   for(i=0; i < 5; i++) { // hacky_nonpointerを繰り返し用いて文字の配列要素を取得
      printf("[hacky_nonpointer]は%pを指しており、その内容は'%c'です。\n",
            hacky_nonpointer, *((char *) hacky_nonpointer));
      hacky_nonpointer = hacky_nonpointer + sizeof(char);
   }

   hacky_nonpointer = (unsigned int) int_array;

   for(i=0; i < 5; i++) { // hacky_nonpointerを繰り返し用いて整数の配列要素を取得
      printf("[hacky_nonpointer]は%pを指しており、その内容は%dです。\n",
            hacky_nonpointer, *((int *) hacky_nonpointer));
      hacky_nonpointer = hacky_nonpointer + sizeof(int);
   }
}
