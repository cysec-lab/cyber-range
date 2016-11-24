#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h> 
#include <netinet/in.h> 
int main(int argc, char *argv[]) { 
   struct sockaddr_in addr; 
   if(argc != 3) {
      printf("使用方法： %s ＜攻撃対象IPアドレス＞ ＜攻撃対象ポート＞\n", argv[0]); 
      exit(0); 
   } 
   addr.sin_family = AF_INET; 
   addr.sin_port = htons(atoi(argv[2])); 
   addr.sin_addr.s_addr = inet_addr(argv[1]); 

   write(1, &addr, sizeof(struct sockaddr_in)); 
} 
