#include <stdio.h>

int main() { 
   int int_var = 5; 
   int *int_ptr;

   int_ptr = &int_var; // int_varのアドレスをint_ptrに設定する

   printf("int_ptr = 0x%08x\n", int_ptr); 
   printf("&int_ptr = 0x%08x\n", &int_ptr); 
   printf("*int_ptr = 0x%08x\n\n", *int_ptr);

   printf("int_varの格納場所：0x%08x その内容：%d\n", &int_var, int_var); 
   printf("int_ptrの格納場所：0x%08x その内容：0x%08x 指している内容：%d\n\n",
      &int_ptr, int_ptr, *int_ptr);
}
