#include <stdio.h>

int j = 42; // jは大域変数

void func3() { 
   int i = 11, j = 999; // このjはfunc3()の局所変数
   printf("\t\t\t[func3内] i @ 0x%08x = %d\n", &i, i); 
   printf("\t\t\t[func3内] j @ 0x%08x = %d\n", &j, j);
}

void func2() { 
   int i = 7;
   printf("\t\t[func2内] i @ 0x%08x = %d\n", &i, i); 
   printf("\t\t[func2内] j @ 0x%08x = %d\n", &j, j); 
   printf("\t\t[func2内] jに1337を代入します。\n"); 
   j = 1337; // jへの代入
   func3(); 
   printf("\t\t[func2に戻ってきました] i @ 0x%08x = %d\n", &i, i); 
   printf("\t\t[func2に戻ってきました] j @ 0x%08x = %d\n", &j, j);
}

void func1() { 
   int i = 5;
   printf("\t[func1内] i @ 0x%08x = %d\n", &i, i); 
   printf("\t[func1内] j @ 0x%08x = %d\n", &j, j); 
   func2(); 
   printf("\t[func1に戻ってきました] i @ 0x%08x = %d\n", &i, i); 
   printf("\t[func1に戻ってきました] j @ 0x%08x = %d\n", &j, j);
}

int main() { 
   int i = 3;
   printf("[main内] i @ 0x%08x = %d\n", &i, i); 
   printf("[main内] j @ 0x%08x = %d\n", &j, j); 
   func1(); 
   printf("[mainに戻ってきました] i @ 0x%08x = %d\n", &i, i); 
   printf("[mainに戻ってきました] j @ 0x%08x = %d\n", &j, j);
}
