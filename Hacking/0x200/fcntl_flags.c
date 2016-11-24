#include <stdio.h> 
#include <fcntl.h>

void display_flags(char *, unsigned int); 
void binary_print(unsigned int);

int main(int argc, char *argv[]) {
   display_flags("O_RDONLY\t\t", O_RDONLY); 
   display_flags("O_WRONLY\t\t", O_WRONLY); 
   display_flags("O_RDWR\t\t\t", O_RDWR);
   printf("\n"); 
   display_flags("O_APPEND\t\t", O_APPEND);
   display_flags("O_TRUNC\t\t\t", O_TRUNC); 
   display_flags("O_CREAT\t\t\t", O_CREAT);

   printf("\n"); 
   display_flags("O_WRONLY|O_APPEND|O_CREAT", O_WRONLY|O_APPEND|O_CREAT);
}

void display_flags(char *label, unsigned int value) { 
   printf("%s\t: %d\t:", label, value); 
   binary_print(value); 
   printf("\n");
}

void binary_print(unsigned int value) { 
   unsigned int mask = 0xff000000;   // 最上位バイトを取得するマスクを作成しておく。
   unsigned int shift = 256*256*256; // 最上位バイトを取得するシフト係数を作成しておく。
   unsigned int byte, byte_iterator, bit_iterator;

   for(byte_iterator=0; byte_iterator < 4; byte_iterator++) { 
      byte = (value & mask) / shift; // 必要なバイトを切り出す。
      printf(" "); 
      for(bit_iterator=0; bit_iterator < 8; bit_iterator++) { // 該当バイトのビットを表示する。
         if(byte & 0x80)    // 該当バイトの最上位ビットが0でない場合、
            printf("1");       // 1を表示する。
         else 
            printf("0");       // さもなければ0を表示する。
         byte *= 2;         // すべてのビットを左に1つだけ移動させる。
      }
      mask /= 256;       // マスクのビットを右に8つ移動させる。
      shift /= 256;      // シフト係数のビットを右に8つ移動させる。
   }
}
