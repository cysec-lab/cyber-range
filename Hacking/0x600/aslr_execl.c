#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
   int stack_var;

   // 現在のスタックフレームからアドレスを出力する。
   printf("stack_var は %p にあります。\n", &stack_var);

   // スタックの配置を確認するためにaslr_demoを起動する。
   execl("./aslr_demo", "aslr_demo", NULL);
}
