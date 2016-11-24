#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include "hacking.h"

#define PORT 7890 // ユーザが接続するポート番号

int main(void) {
   int sockfd, new_sockfd;  // sockfd上で待ち受ける、new_fdは新たな接続
   struct sockaddr_in host_addr, client_addr;   // 自らのアドレス情報
   socklen_t sin_size;
   int recv_length=1, yes=1;
   char buffer[1024];

   if ((sockfd = socket(PF_INET, SOCK_STREAM, 0)) == -1)
      fatal("ソケットが生成できませんでした。");

   if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1)
      fatal("ソケットを SO_REUSEADDR に設定します。"); 

  host_addr.sin_family = AF_INET;    // ホストのバイト順
  host_addr.sin_port = htons(PORT);  // 短整数、ネットワークバイト順
  host_addr.sin_addr.s_addr = 0; // 自動的に自身のIPが設定される
  memset(&(host_addr.sin_zero), '\0', 8); // 構造体の残り部分はゼロに

    
  if (bind(sockfd, (struct sockaddr *)&host_addr, sizeof(struct sockaddr)) == -1)
    fatal("ソケットのバインドに失敗しました。");

  if (listen(sockfd, 5) == -1)
    fatal("ソケットの待ち受けで失敗しました。");

  while(1) {    // Acceptループ
      sin_size = sizeof(struct sockaddr_in);
      new_sockfd = accept(sockfd, (struct sockaddr *)&client_addr, &sin_size);
      if(new_sockfd == -1)
         fatal("コネクションの受付で失敗しました。");
      printf("サーバ： %s のポート %d からのコネクションを受け付けました。\n",
      inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));
      send(new_sockfd, "Hello, world!\n", 13, 0);
      recv_length = recv(new_sockfd, &buffer, 1024, 0);
      while(recv_length > 0) {
         printf("受信： %d バイト受信しました。\n", recv_length);
         dump(buffer, recv_length);
         recv_length = recv(new_sockfd, &buffer, 1024, 0);
      }
      close(new_sockfd);
   }
   return 0;
}
