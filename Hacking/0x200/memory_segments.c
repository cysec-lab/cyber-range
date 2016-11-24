#include <stdio.h> 

int global_var;
int global_initialized_var = 5;

void function() { // これはただのデモ用関数
   int stack_var; // この変数はmain()内の変数と同じ名前となっている
   
   printf("function()のstack_varは、アドレス0x%08xにあります。\n", &stack_var);
}

int main() { 
   int stack_var; // function()内と同じ名前の変数
   static int static_initialized_var = 5; 
   static int static_var; 
   int *heap_var_ptr;

   heap_var_ptr = (int *) malloc(4);

   // 以下の変数はデータセグメント内に確保される
   printf("global_initialized_varはアドレス0x%08xにあります。\n",
         &global_initialized_var); 
   printf("static_initialized_varはアドレス0x%08xにあります。\n\n",
         &static_initialized_var);

   // 以下の変数はbssセグメント内に確保される
   printf("static_varはアドレス0x%08xにあります。\n", &static_var); 
   printf("global_varはアドレス0x%08xにあります。\n\n", &global_var);

   // 以下のポインタ変数はヒープセグメント内を指し示す
   printf("heap_var_ptrはアドレス0x%08xを指しています。\n\n", heap_var_ptr);

   // 以下の変数はスタックセグメント内に確保される
   printf("stack_varはアドレス0x%08xにあります。\n", &stack_var); 
   function();
}
