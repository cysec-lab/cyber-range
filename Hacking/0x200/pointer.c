#include <stdio.h> 
#include <string.h>

int main() { 
   char str_a[20];  // 20個の要素を持つ文字の配列
   char *pointer;   // 文字の配列を指すポインタ
   char *pointer2;  // 同じく、文字の配列を指すポインタ

   strcpy(str_a, "Hello, world!\n");
   pointer = str_a; // 1つ目のポインタが配列の先頭を指すように設定する
   printf(pointer); // 1つ目のポインタが指している文字列を表示する

   pointer2 = pointer + 2; // 2つ目のポインタは2バイト先を指すように設定する
   printf(pointer2);       // 2つ目のポインタが指している文字列を表示する
   strcpy(pointer2, "y you guys!\n"); // その場所に他の文字列をコピーする
   printf(pointer);        // 1つ目のポインタが指している文字列を表示する
}
