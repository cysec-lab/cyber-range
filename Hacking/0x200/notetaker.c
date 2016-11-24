#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <fcntl.h> 
#include <sys/stat.h> 
#include "hacking.h"

void usage(char *prog_name, char *filename) { 
   printf("使用方法： %s <%sに追加するデータ>\n", prog_name, filename); 
   exit(0);
}

void fatal(char *);            // 致命的なエラーが発生した際に使用する関数
void *ec_malloc(unsigned int); // malloc()をエラー判定でラップした関数

int main(int argc, char *argv[]) {
   int userid, fd; // ファイル記述子
   char *buffer, *datafile;

   buffer = (char *) ec_malloc(100); 
   datafile = (char *) ec_malloc(20); 
   strcpy(datafile, "/var/notes");

   if(argc < 2)                 // コマンドライン引数が与えられていない場合、
      usage(argv[0], datafile); // 使用方法を表示して終了する。

   strcpy(buffer, argv[1]);  // コマンドライン引数をバッファにコピーする。

   printf("[DEBUG] buffer   @ %p: \'%s\'\n", buffer, buffer); 
   printf("[DEBUG] datafile @ %p: \'%s\'\n", datafile, datafile);

// ファイルのオープン
   fd = open(datafile, O_WRONLY|O_CREAT|O_APPEND, S_IRUSR|S_IWUSR); 
   if(fd == -1)
      fatal("main()内、ファイルのオープン中にエラーが発生しました。"); 
   printf("[DEBUG] ファイル記述子：%d\n", fd);

   userid = getuid(); // 実ユーザIDを取得する。

// データの書き込み
   if(write(fd, &userid, 4) == -1) // メモの前にユーザIDを書き込む。
      fatal("main()内、ファイルへのユーザIDの書き込みでエラーが発生しました。");
   write(fd, "\n", 1); // 改行する。

   if(write(fd, buffer, strlen(buffer)) == -1) // メモを書き込む。
      fatal("main()内、ファイルへのバッファの書き込みでエラーが発生しました。"); 
   write(fd, "\n", 1); // 改行する。

// ファイルのクローズ
   if(close(fd) == -1) 
      fatal("main()内、ファイルのクローズ中にエラーが発生しました。");

   printf("メモが保存されました\n");
   free(buffer); 
   free(datafile);
}
