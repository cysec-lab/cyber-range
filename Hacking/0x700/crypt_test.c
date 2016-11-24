#define _XOPEN_SOURCE
#include <unistd.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
   if(argc < 2) { 
      printf("使用方法： %s ＜平文のパスワード＞ ＜salt値＞\n", argv[0]);
      exit(1); 
   }
   printf("パスワード = \"%s\", salt値 = \"%s\", ", argv[1], argv[2]);
   printf("ハッシュ値 ==> %s\n", crypt(argv[1], argv[2]));
}
