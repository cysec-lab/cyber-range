#include <stdio.h>
#include <stdlib.h>

static void cleanup(void) __attribute__ ((destructor));

main()
{
  printf("main() 関数内で処理を行い、、\n");
  printf("その後、main() の終了時にデストラクタが呼び出される。\n");

  exit(0);
}

void cleanup(void)
{
  printf("後始末関数の処理中、、、\n");
}
