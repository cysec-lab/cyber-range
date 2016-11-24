#include <unistd.h>

int main() {
  char filename[] = "/bin/sh\x00";
  char **argv, **envp; // charへのポインタを保持した配列

  argv[0] = filename; // 唯一の引数はファイル名
  argv[1] = 0;  // 引数の配列をnullで終端する

  envp[0] = 0; // 環境の配列をnullで終端する

  execve(filename, argv, envp);
}
