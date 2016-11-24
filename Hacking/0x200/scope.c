#include <stdio.h>

void func3() { 
   int i = 11;
   printf("\t\t\t[func3内] i = %d\n", i);
}

void func2() { 
   int i = 7;
   printf("\t\t[func2内] i = %d\n", i); 
   func3(); 
   printf("\t\t[func2に戻ってきました] i = %d\n", i);
}

void func1() { 
   int i = 5;
   printf("\t[func1内] i = %d\n", i); 
   func2(); 
   printf("\t[func1に戻ってきました] i = %d\n", i);
}

int main() { 
   int i = 3;
   printf("[main内] i = %d\n", i); 
   func1(); 
   printf("[mainに戻ってきました] i = %d\n", i);
}
