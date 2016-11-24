#include <sys/stat.h> 
#include <sys/socket.h> 
#include <netinet/in.h> 
#include <arpa/inet.h> 
#include <sys/types.h> 
#include <sys/stat.h> 
#include <fcntl.h> 
#include <time.h> 
#include <signal.h> 
#include "hacking.h" 
#include "hacking-network.h" 

#define PORT 80   // ユーザが接続することになるポート
#define WEBROOT "./webroot" // ウェブサーバのルートディレクトリ
#define LOGFILE "/var/log/tinywebd.log" // ログファイルの名称

int logfd, sockfd;  // ログファイルとソケットファイルの記述し（大域変数）
void handle_connection(int, struct sockaddr_in *, int); 
int get_file_size(int); // オープンしているファイル記述子のファイルサイズを返す
void timestamp(int); // オープンしているファイル記述子にタイムスタンプを書き込む

// この関数は、プロセスがkillされた際に呼び出される。
void handle_shutdown(int signal) { 
   timestamp(logfd); 
   write(logfd, "シャットダウンします。\n", 16); 
   close(logfd); 
   close(sockfd); 
   exit(0); 
} 

int main(void) { 
   int new_sockfd, yes=1; 
   struct sockaddr_in host_addr, client_addr;   // 自分のアドレス情報
   socklen_t sin_size; 

   logfd = open(LOGFILE, O_WRONLY|O_CREAT|O_APPEND, S_IRUSR|S_IWUSR); 
   if(logfd == -1) 
      fatal("ログファイルのオープンに失敗しました。"); 

   if ((sockfd = socket(PF_INET, SOCK_STREAM, 0)) == -1) 
      fatal("ソケットの生成に失敗しました。"); 

   if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1) 
      fatal("ソケットオプションSO_REUSEADDRの設定に失敗しました。"); 

   printf("tinywebデーモンを開始します。\n"); 
   if(daemon(1, 0) == -1) // バックグラウンドのデーモンプロセスをフォークする。
      fatal("デーモンプロセスのフォークに失敗しました。"); 

   signal(SIGTERM, handle_shutdown);   // killされた際にhandle_shutdownを呼び出す。
   signal(SIGINT, handle_shutdown);   // 割り込まれた際にhandle_shutdownを呼び出す。
   
   timestamp(logfd); 
   write(logfd, "起動中。\n", 15); 
   host_addr.sin_family = AF_INET;      // ホストのバイト順
   host_addr.sin_port = htons(PORT);    // ネットワークのバイト順（短整数）
   host_addr.sin_addr.s_addr = INADDR_ANY; // 自分のIPを自動的に設定する。
   memset(&(host_addr.sin_zero), '\0', 8); // 構造体の残り部分をゼロクリアする。

   if (bind(sockfd, (struct sockaddr *)&host_addr, sizeof(struct sockaddr)) == -1) 
      fatal("ソケットのバインドに失敗しました。"); 

   if (listen(sockfd, 20) == -1) 
      fatal("ソケットの待ち受けに失敗しました。"); 

   while(1) { // 受け付けループ
      sin_size = sizeof(struct sockaddr_in); 
      new_sockfd = accept(sockfd, (struct sockaddr *)&client_addr, &sin_size); 
      if(new_sockfd == -1) 
         fatal("コネクションの受け付けに失敗しました。"); 

      handle_connection(new_sockfd, &client_addr, logfd); 
   } 
   return 0; 
} 

/* この関数は引き渡されたクライアントアドレスからのソケットに対するコネクションを
 * 取り扱い、引き渡されたFDにログを出力する。このコネクションはウェブリクエスト
 * として処理され、この関数は接続されたソケットを介して応答する。最後に、関数の
 * 最後で引き渡されたソケットをクローズする。
 */
void handle_connection(int sockfd, struct sockaddr_in *client_addr_ptr, int logfd) {
   unsigned char *ptr, request[500], resource[500], log_buffer[500]; 
   int fd, length; 

   length = recv_line(sockfd, request); 

   sprintf(log_buffer, "%s:%d より \"%s\"\t", inet_ntoa(client_addr_ptr->sin_addr), ntohs(client_addr_ptr->sin_port), request); 

   ptr = strstr(request, " HTTP/"); // 有効に見えるリクエストを検索する。
   if(ptr == NULL) { // そのリクエストが有効なHTTPリクエストでない場合、
      strcat(log_buffer, " HTTPではない！\n"); 
   } else { 
      *ptr = 0; // URLの末尾でバッファを終端する。
      ptr = NULL; // ptrにNULLを設定する（不正なリクエストに対するフラグとして使用）。
      if(strncmp(request, "GET ", 4) == 0)  // GETリクエスト
         ptr = request+4; // ptrはURLである。
      if(strncmp(request, "HEAD ", 5) == 0) // HEADリクエスト 
         ptr = request+5; // ptrはURLである。
      if(ptr == NULL) { // それ以外の場合、認識可能なリクエストではない。
         strcat(log_buffer, " 不明なリクエスト！\n"); 
      } else { // リソース名を指すptrを伴った有効なリクエスト
         if (ptr[strlen(ptr) - 1] == '/')  // '/'で終了するリソースについては、
            strcat(ptr, "index.html");     // 末尾に'index.html'を付加する。
         strcpy(resource, WEBROOT);     // ウェブのルートパスからリソースを開始し、
         strcat(resource, ptr);         //  リソースパスを付加する。
         fd = open(resource, O_RDONLY, 0); // 該当ファイルのオープンを試みる。
         if(fd == -1) { // ファイルが存在しない場合、
            strcat(log_buffer, " 404 Not Found\n"); 
            send_string(sockfd, "HTTP/1.0 404 NOT FOUND\r\n"); 
            send_string(sockfd, "Server: Tiny webserver\r\n\r\n"); 
            send_string(sockfd, "<html><head><title>404 Not Found</title></head>"); 
            send_string(sockfd, "<body><h1>URL not found</h1></body></html>\r\n"); 
         } else {      // ファイルが存在する場合、そのファイルを応答する。
            strcat(log_buffer, " 200 OK\n"); 
            send_string(sockfd, "HTTP/1.0 200 OK\r\n"); 
            send_string(sockfd, "Server: Tiny webserver\r\n\r\n"); 
            if(ptr == request + 4) { // これはGETリクエストである
               if( (length = get_file_size(fd)) == -1) 
                  fatal("リソースファイルのサイズ取得に失敗しました。"); 
               if( (ptr = (unsigned char *) malloc(length)) == NULL) 
                  fatal("リソース読み込み時のメモリ割り当てに失敗しました。"); 
               read(fd, ptr, length); // ファイルをメモリに読み込む。
               send(sockfd, ptr, length, 0);  // ソケットへと送信する。
               free(ptr); // メモリを解放する。
         } 
         close(fd); // ファイルをクローズする。
         } // ファイルの有無チェックを行うifブロックの終了。
      } // 有効なリクエストかどうかをチェックするifブロックの終了。
   } // 有効なHTTPかどうかをチェックするifブロックの終了。
   timestamp(logfd); 
   length = strlen(log_buffer); 
   write(logfd, log_buffer, length); // ログの出力。

   shutdown(sockfd, SHUT_RDWR); // ソケットを適切にクローズする。
}

/* この関数はオープンされたファイル記述子を受け取り、関連するファイルの
 * サイズを返す。失敗した際には-1を返す。
 */ 
int get_file_size(int fd) { 
   struct stat stat_struct; 

   if(fstat(fd, &stat_struct) == -1) 
      return -1; 
   return (int) stat_struct.st_size; 
} 

/* この関数は、引き渡されたオープンしているファイル記述子にタイムスタンプを
 * 文字列として出力する。
 */ 
void timestamp(fd) { 
   time_t now; 
   struct tm *time_struct; 
   int length; 
   char time_buffer[40]; 

   time(&now);  // 起原からの経過秒数を取得する。
   time_struct = localtime((const time_t *)&now); // tm構造体へと変換する。
   length = strftime(time_buffer, 40, "%m/%d/%Y %H:%M:%S> ", time_struct); 
   write(fd, time_buffer, length); // タイムスタンプを文字列としてログに出力する。
} 
