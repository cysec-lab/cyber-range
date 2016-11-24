#include <stdio.h>

int main() { 
   int a, b;
   float c, d;

   a = 13; 
   b = 5;

   c = a / b;                  // 整数による除算
   d = (float) a / (float) b;  // 整数を浮動小数点にキャストした後の除算
   
   printf("[整数]         a = %d\t\t b = %d\n", a, b); 
   printf("[浮動小数点数] c = %f\t d = %f\n", c, d);
}
