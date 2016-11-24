/*********************************************************\
*  Password Probability Matrix   *    File: ppm_gen.c     *
***********************************************************
*                                                         *
*  Author:        Jon Erickson <matrix@phiral.com>        *
*  Organization:  Phiral Research Laboratories            *
*                                                         *
*  This is the generate program for the PPM proof of      *
*  concept.  It generates a file called 4char.ppm, which  *
*  contains information regarding all possible 4-         *
*  character passwords salted with 'je'.  This file can   *
*  be used to quickly crack passwords found within this   *
*  keyspace with the corresponding ppm_crack.c program.   *
*                                                         *
\*********************************************************/

#define _XOPEN_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#define HEIGHT 16384
#define WIDTH  1129
#define DEPTH  8
#define SIZE HEIGHT * WIDTH * DEPTH

/* ハッシュバイトを列挙値にマップする。 */
int enum_hashbyte(char a) {
   int i, j;
   i = (int)a;
   if((i >= 46) && (i <= 57))
      j = i - 46;
   else if ((i >= 65) && (i <= 90))
      j = i - 53;
   else if ((i >= 97) && (i <= 122))
      j = i - 59;
   return j;
}

/* 3つのハッシュバイトを列挙値にマップする。 */
int enum_hashtriplet(char a, char b, char c) {
   return (((enum_hashbyte(c)%4)*4096)+(enum_hashbyte(a)*64)+enum_hashbyte(b));
}
/* メッセージを表示して終了する。 */
void barf(char *message, char *extra) {
   printf(message, extra);
   exit(1);
}

/* 考えられる4文字のパスワードすべて（saltはje）を用いて4-char.ppmファイルを生成する。 */
int main() {
   char plain[5];
   char *code, *data;
   int i, j, k, l;
   unsigned int charval, val;
   FILE *handle;
   if (!(handle = fopen("4char.ppm", "w")))
      barf("エラー： '4char.ppm' を書き込みモードでオープンできませんでした。\n", NULL);

   data = (char *) malloc(SIZE);
   if (!(data))
      barf("エラー： メモリを割り当てることができませんでした。\n", NULL);

   for(i=32; i<127; i++) {
      for(j=32; j<127; j++) {
         printf("4char.ppm に %c%c** を追加しています...\n", i, j);
         for(k=32; k<127; k++) {
            for(l=32; l<127; l++) {

               plain[0]  = (char)i; // Build every
               plain[1]  = (char)j; // possible 4-byte
               plain[2]  = (char)k; // password.
               plain[3]  = (char)l;
               plain[4]  = '\0';
               code = crypt((const char *)plain, (const char *)"je"); // Hash it.

               /* ペアに関する非可逆領域の統計情報 */
               val = enum_hashtriplet(code[2], code[3], code[4]); // バイト2-4の情報を格納する。
               charval = (i-32)*95 + (j-32); // 平文の最初の2バイト
               data[(val*WIDTH)+(charval/8)] |=  (1<<(charval%8));
               val += (HEIGHT * 4);
               charval = (k-32)*95 + (l-32); // 平文の最後の2バイト
               data[(val*WIDTH)+(charval/8)] |=  (1<<(charval%8));

               val = HEIGHT + enum_hashtriplet(code[4], code[5], code[6]); // 4-6バイト
               charval = (i-32)*95 + (j-32); // 平文の最初の2バイト
               data[(val*WIDTH)+(charval/8)] |=  (1<<(charval%8));
               val += (HEIGHT * 4);
               charval = (k-32)*95 + (l-32); // 平文の最後の2バイト
               data[(val*WIDTH)+(charval/8)] |=  (1<<(charval%8));

               val = (2 * HEIGHT) + enum_hashtriplet(code[6], code[7], code[8]); // 6-8バイト
               charval = (i-32)*95 + (j-32); // 平文の最初の2バイト
               data[(val*WIDTH)+(charval/8)] |=  (1<<(charval%8));
               val += (HEIGHT * 4);
               charval = (k-32)*95 + (l-32); // 平文の最後の2バイト
               data[(val*WIDTH)+(charval/8)] |=  (1<<(charval%8));

               val = (3 * HEIGHT) + enum_hashtriplet(code[8], code[9], code[10]); // 8-10バイト
               charval = (i-32)*95 + (j-32); // 平文の最初の2バイト
               data[(val*WIDTH)+(charval/8)] |=  (1<<(charval%8));
               val += (HEIGHT * 4);
               charval = (k-32)*95 + (l-32); // 平文の最後の2バイト
               data[(val*WIDTH)+(charval/8)] |=  (1<<(charval%8));
            }
         }
      }
   }
   printf("完了しました... 保存中です\n");
   fwrite(data, SIZE, 1, handle);
   free(data);
   fclose(handle);
}
