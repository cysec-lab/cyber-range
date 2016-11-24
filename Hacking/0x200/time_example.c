#include <stdio.h> 
#include <time.h>

int main() { 
   long int seconds_since_epoch; 
   struct tm current_time, *time_ptr; 
   int hour, minute, second, day, month, year;

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
}
