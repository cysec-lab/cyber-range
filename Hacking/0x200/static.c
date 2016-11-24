#include <stdio.h>

void function() { // functionは独自のコンテキストを持つ
   int var = 5; 
   static int static_var = 5; // 静的変数の初期化
   
   printf("\t[function内] var = %d\n", var); 
   printf("\t[function内] static_var = %d\n", static_var); 
   var++;          // varの値をインクリメント
   static_var++;   // static_varの値をインクリメント
}

int main() { // mainは独自のコンテキストを持つ
   int i;
   static int static_var = 1337; // 独立したコンテキスト内における独立した静的変数
   
   for(i=0; i < 5; i++) { // 5回繰り返す
      printf("[main内] static_var = %d\n", static_var); 
      function(); // functionを呼び出す
   }
}
