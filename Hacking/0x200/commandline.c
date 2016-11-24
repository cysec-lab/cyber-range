#include <stdio.h>

int main(int arg_count, char *arg_list[]) { 
   int i;
   printf("%d個のコマンドライン引数が与えられました：\n", arg_count); 
   for(i=0; i < arg_count; i++)
      printf("引数#%d： %s\n", i, arg_list[i]);
}
