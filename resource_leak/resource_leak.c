#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>

int main(int argc, char *argv[]) {
    char data[10] = "test data";
    char *p;
    pid_t pid;

    if((pid = fork()) ==0) {
        /* 子プロセス */
        
        /* detach */
        //signal (SIGCHLD, SIG_IGN);
        //signal (SIGHUP, SIG_IGN);
        
        /* 領域を確保 */
        p = (char *)malloc(sizeof(char) * 1024 * 1024);
        if (p == NULL) {
            printf("メモリ確保エラー\n");
            return -1;
        }

        /* 確保した領域をクリア */
        memset(p, '\0', sizeof(data));

        /* 確保した領域にデータを設定 */
        strcpy(p, data);
        //printf("ptr=%s\n", p);

        /* 確保した領域を解放 */
        // free(p);
        
        while(1);
    } else if(pid > 0) {
        /* 親プロセス */
//        printf("parent pid=%d\n", getpid());
//        printf("child pid=%d\n", pid);
    } else {
        /* エラー */
        printf("error\n");
        return -1;
    }

    return 0;
}

