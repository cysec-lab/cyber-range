#include <stdio.h>

int main() { 
   char string[10]; 
   int A = -73; 
   unsigned int B = 31337;

   strcpy(string, "sample");

   // さまざまなフォーマット文字列を用いた表示の例
   printf("[A] 10進：%d, 16進：%x, 符号無し10進：%u\n", A, A, A); 
   printf("[B] 10進：%d, 16進：%x, 符号無し10進：%u\n", B, B, B); 
   printf("[Bのフィールド幅指定] 3: '%3u', 10: '%10u', '%08u'\n", B, B, B); 
   printf("[文字列] %s アドレス %08x\n", string, string);

   // 単項アドレス演算子（アドレス取得）と%xフォーマット文字列の例
   printf("変数Aのアドレス：%08x\n", &A);
}
