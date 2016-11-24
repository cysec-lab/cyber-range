#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main(void) {
   int sockfd, new_sockfd;  // sock_fdは待ち受けるソケット。new_fdはコネクション記述子
   struct sockaddr_in host_addr, client_addr;   // 自らのアドレス情報
   socklen_t sin_size;
   int yes=1;

   sockfd = socket(PF_INET, SOCK_STREAM, 0);

   host_addr.sin_family = AF_INET;         // ホストのバイト順序
   host_addr.sin_port = htons(31337);      // ネットワークバイト順にする（short）
   host_addr.sin_addr.s_addr = INADDR_ANY; // 自らのIPを自動設定する
   memset(&(host_addr.sin_zero), '\0', 8); // 構造体の残り部分をゼロクリアする

   bind(sockfd, (struct sockaddr *)&host_addr, sizeof(struct sockaddr));

   listen(sockfd, 4);

   sin_size = sizeof(struct sockaddr_in);
   new_sockfd = accept(sockfd, (struct sockaddr *)&client_addr, &sin_size);
}
