#include <stdio.h>

void usage(char *program_name) { 
   printf("使用方法： %s <メッセージ> <繰り返し回数>\n", program_name); 
   exit(1);
}

int main(int argc, char *argv[]) { 
   int i, count;

   if(argc < 3)       // 引数の数が3未満の場合、
      usage(argv[0]); // 使用方法を表示して終了する。

   count = atoi(argv[2]); // 2番目の引数を整数に変換する。
   printf("%d回繰り返します。\n", count);

   for(i=0; i < count; i++) 
      printf("%3d - %s\n", i, argv[1]); // 最初の引数を表示する。
}
