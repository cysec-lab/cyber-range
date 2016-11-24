#include <stdio.h> 
#include <time.h>

void dump_time_struct_bytes(struct tm *time_ptr, int size) { 
   int i;
   unsigned char *raw_ptr;

   printf("0x%08x にある構造体の内容\n", time_ptr);
   raw_ptr = (unsigned char *) time_ptr; 
   for(i=0; i < size; i++) 
   {
      printf("%02x ", raw_ptr[i]); 
      if(i%16 == 15) // 16バイトごとに改行を出力する。
         printf("\n"); 
   }
   printf("\n");
}

int main() { 
   long int seconds_since_epoch; 
   struct tm current_time, *time_ptr; 
   int hour, minute, second, i, *int_ptr;

   seconds_since_epoch = time(0); // timeに引数としてnullポインタを渡す。
   printf("time() - エポックからの通算秒数： %ld\n", seconds_since_epoch);

   time_ptr = &current_time;  // time_ptrにcurrent_time構造体の
                              // 先頭アドレスを設定する。
   localtime_r(&seconds_since_epoch, time_ptr);

   // 構造体の要素にアクセスするための3つの方法
   hour = current_time.tm_hour;  // 直接アクセス
   minute = time_ptr->tm_min;    // ポインタ経由でのアクセス
   second = *((int *) time_ptr); // 技巧的なポインタアクセス

   printf("現在の時間は： %02d:%02d:%02d\n", hour, minute, second); 

   dump_time_struct_bytes(time_ptr, sizeof(struct tm));

   minute = hour = 0;  // 分と時をクリアする。
   int_ptr = (int *) time_ptr;

   for(i=0; i < 3; i++) { 
      printf("int_ptr @ 0x%08x : %d\n", int_ptr, *int_ptr); 
      int_ptr++; // intのサイズは4バイトであるため、int_ptrに
   }             // 1を加算することで、アドレスは4バイト増加する。
}
