#include <stdio.h>

int func_one() { 
   printf("これは1つ目の関数です。\n"); 
   return 1;
}

int func_two() { 
   printf("これは2つ目の関数です。\n"); 
   return 2;
}

int main() { 
   int value;
   int (*function_ptr) ();

   function_ptr = func_one; 
   printf("function_ptr： 0x%08x\n", function_ptr); 
   value = function_ptr(); 
   printf("戻り値： %d\n", value);

   function_ptr = func_two; 
   printf("function_ptr： 0x%08x\n", function_ptr); 
   value = function_ptr(); 
   printf("戻り値： %d\n", value);
}
