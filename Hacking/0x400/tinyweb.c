#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "hacking.h"
#include "hacking-network.h"

#define PORT 80   // ユーザが接続することになるポート
#define WEBROOT "./webroot" // ウェブサーバのルートディレクトリ

void handle_connection(int, struct sockaddr_in *); // ウェブリクエストを取り扱う
int get_file_size(int); // オープンするファイル記述子のファイルサイズを返す。

int main(void) {
   int sockfd, new_sockfd, yes=1;
   struct sockaddr_in host_addr, client_addr;   // 自らのアドレス情報
   socklen_t sin_size;

   printf("ポート %d のウェブリクエストを受け付けます。\n", PORT);

   if ((sockfd = socket(PF_INET, SOCK_STREAM, 0)) == -1)
      fatal("ソケットが生成できませんでした。");

   if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1)
      fatal("ソケットを SO_REUSEADDR に設定します。");

   host_addr.sin_family = AF_INET;      // ホストのバイト順
   host_addr.sin_port = htons(PORT);    // ネットワークバイト順の短整数
   host_addr.sin_addr.s_addr = INADDR_ANY; // 自動的に自らのIPを設定する
   memset(&(host_addr.sin_zero), '\0', 8); // 構造体の残りをゼロクリアする

   if (bind(sockfd, (struct sockaddr *)&host_addr, sizeof(struct sockaddr)) == -1)
      fatal("ソケットのバインドに失敗しました。");

   if (listen(sockfd, 20) == -1)
      fatal("ソケットの待ち受けで失敗しました。");

   while(1) {   // 受け付けのループ
      sin_size = sizeof(struct sockaddr_in);
      new_sockfd = accept(sockfd, (struct sockaddr *)&client_addr, &sin_size);
      if(new_sockfd == -1)
         fatal("コネクションの受付で失敗しました。");

      handle_connection(new_sockfd, &client_addr);
   }
   return 0;
}

/* この関数は、引き渡されたクライアントのアドレスからのソケットに対する
 * 接続を取り扱うものである。　接続はウェブリクエストとして処理され、
 * この関数は接続されたソケット経由で応答を行う。　最終的に引き渡された
 * ソケットは関数の最後でクローズされる。
 */
void handle_connection(int sockfd, struct sockaddr_in *client_addr_ptr) {
   unsigned char *ptr, request[500], resource[500];
   int fd, length;
   
   length = recv_line(sockfd, request);
   
   printf("%s：%d からリクエストを受け取りました \"%s\"\n", inet_ntoa(client_addr_ptr->sin_addr), ntohs(client_addr_ptr->sin_port), request);

   ptr = strstr(request, " HTTP/"); // 有効に見えるリクエストを検索する。
   if(ptr == NULL) { // これは有効はHTTPリクエストではない。
      printf(" HTTPではない！\n");
   } else {
      *ptr = 0; // URLの末尾でバッファを終端させる。
      ptr = NULL; // ptrにNULLを設定する（無効なリクエストのフラグとして使用）。
      if(strncmp(request, "GET ", 4) == 0)  // GETリクエスト
         ptr = request+4; // ptrはURLである。
      if(strncmp(request, "HEAD ", 5) == 0) // HEADリクエスト
         ptr = request+5; // ptrはURLである。

      if(ptr == NULL) { // これは認識できるリクエストではない。
         printf("\t不明なリクエスト！\n");
      } else { // 有効なリクエスト。　ptrがリソース名を指している。
         if (ptr[strlen(ptr) - 1] == '/')  // '/'で終わっているリソースの場合、
            strcat(ptr, "index.html");     // 末尾に'index.html'を追加する。
         strcpy(resource, WEBROOT);     // ウェブのルートパスをresourceから開始し
         strcat(resource, ptr);         //  リソースのパスを追加していく。
         fd = open(resource, O_RDONLY, 0); // ファイルのオープンを試みる。
         printf("\t\'%s\' のオープン\t", resource);
         if(fd == -1) { // ファイルが見つからない場合、
            printf(" 404 Not Found\n");
            send_string(sockfd, "HTTP/1.0 404 NOT FOUND\r\n");
            send_string(sockfd, "Server: Tiny webserver\r\n\r\n");
            send_string(sockfd, "<html><head><title>404 Not Found</title></head>");
            send_string(sockfd, "<body><h1>URL not found</h1></body></html>\r\n");
         } else {      // そうでない場合、ファイルの内容を応答する。
            printf(" 200 OK\n");
            send_string(sockfd, "HTTP/1.0 200 OK\r\n");
            send_string(sockfd, "Server: Tiny webserver\r\n\r\n");
            if(ptr == request + 4) { // これはGETリクエストである
               if( (length = get_file_size(fd)) == -1)
                  fatal("リソースファイルのサイズ取得に失敗しました。");
               if( (ptr = (unsigned char *) malloc(length)) == NULL)
                  fatal("リソース読み込み時のメモリ割り当てに失敗しました。");
               read(fd, ptr, length); // ファイルをメモリ内に読み込む。
               send(sockfd, ptr, length, 0);  // それをソケットに送信する。
               free(ptr); // ファイルを格納したメモリ領域を開放する。
            }
            close(fd); // ファイルをクローズする。
         } // ファイルの発見/未発見を処理するブロックの終了
      } // 有効なリクエストを処理するブロックの終了
   } // 有効なHTTPを処理するブロックの終了
   shutdown(sockfd, SHUT_RDWR); // ソケットをクローズする。
}

/* この関数はオープンされているファイル記述子を受け取り、
 * 対応しているファイルのサイズを返す。　失敗した際には-1を返す。
 */
int get_file_size(int fd) {
   struct stat stat_struct;

   if(fstat(fd, &stat_struct) == -1)
      return -1;
   return (int) stat_struct.st_size;
}
