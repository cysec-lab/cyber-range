#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
  int         fd, i;
  char        c;
  struct stat statbuf;

  if (argc != 3) {
    printf("usage : %s file size\n", argv[0]); exit(1);
  }
  if ((fd=open(argv[1], O_RDWR|O_APPEND)) == -1
    || fstat(fd, &statbuf) == -1) {
    perror("erorr"); exit(1);
  }
  for (i = 0; i < atoi(argv[2])-statbuf.st_size; i++) {
    c = rand(); write(fd, &c, 1);
  }
  close(fd);
}

