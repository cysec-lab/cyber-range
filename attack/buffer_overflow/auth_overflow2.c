#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int check_authentication(char *password) {
  char password_buffer[16];
  int auth_flag = 0;

  strcpy(password_buffer, password);

  if (strcmp(password_buffer, "password") == 0)
    auth_flag = 1;
  if (strcmp(password_buffer, "outgrabe") == 0)
    auth_flag = 1;

  return auth_flag;
}

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("使用方法: %s <パスワード>\n", argv[0]);
    exit(0);
  }
  if (check_authentication(argv[1])) {
    printf("-=-=-=-=-=-=-=-=-=-=-=-=-=-\n");
    printf("アクセスを許可します\n");
    printf("-=-=-=-=-=-=-=-=-=-=-=-=-=-\n");
  } else {
      printf("アクセスを拒否しました\n");
  }
}

