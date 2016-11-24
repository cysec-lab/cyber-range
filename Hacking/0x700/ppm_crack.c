/*********************************************************\
*  Password Probability Matrix   *    File: ppm_crack.c   *
***********************************************************
*                                                         *
*  Author:        Jon Erickson <matrix@phiral.com>        *
*  Organization:  Phiral Research Laboratories            *
*                                                         *
*  This is the crack program for the PPM proof of concept.*
*  It uses an existing file called 4char.ppm, which       *
*  contains information regarding all possible 4-         *
*  character passwords salted with 'je'.  This file can   *
*  be generated with the corresponding ppm_gen.c program. *
*                                                         *
\*********************************************************/

#define _XOPEN_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#define HEIGHT 16384
#define WIDTH  1129
#define DEPTH 8
#define SIZE HEIGHT * WIDTH * DEPTH
#define DCM HEIGHT * WIDTH

/* 単一のハッシュバイトを列挙値にマップする。 */
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

/* 2つのベクタを結合する。 */
void merge(char *vector1, char *vector2) {
   int i;
   for(i=0; i < WIDTH; i++)
      vector1[i] &= vector2[i];
}

/* vector内で、引き渡されたindex位置にあるビットを返す。 */
int get_vector_bit(char *vector, int index) {
   return ((vector[(index/8)]&(1<<(index%8)))>>(index%8));
}

/* 引き渡されたベクタ内における平文のペアの数を数える。 */
int count_vector_bits(char *vector) {
   int i, count=0;
   for(i=0; i < 9025; i++)
      count += get_vector_bit(vector, i);
   return count;
}

/* ベクタ列挙内でオンになっているビットに当たる平文のペアを出力する。 */
void print_vector(char *vector) {
   int i, a, b, val;
   for(i=0; i < 9025; i++) {
      if(get_vector_bit(vector, i) == 1) { // ビットがオンである場合、
         a = i / 95;                  // 平文のペアを
         b = i - (a * 95);            // 算出し、
         printf("%c%c ",a+32, b+32);  // 出力する。
      }
   }
   printf("\n");
}

/* メッセージを出力して終了する。 */
void barf(char *message, char *extra) {
   printf(message, extra);
   exit(1);
}

/* 生成された4char.ppmファイルを使用して4文字のパスワードを解読する。 */
int main(int argc, char *argv[]) {
  char *pass, plain[5];
  unsigned char bin_vector1[WIDTH], bin_vector2[WIDTH], temp_vector[WIDTH];
  char prob_vector1[2][9025];
  char prob_vector2[2][9025];
  int a, b, i, j, len, pv1_len=0, pv2_len=0;
  FILE *fd;

  if(argc < 1)
     barf("使用方法： %s ＜パスワードハッシュ＞（4char.ppmファイルを使用）\n", argv[0]);

  if(!(fd = fopen("4char.ppm", "r")))
     barf("エラー： PPM ファイルを読み込みモードでオープンできませんでした。\n", NULL);

  pass = argv[1]; // 最初の引数はパスワードハッシュ

  printf("最初の2文字に対して考えられる平文のバイトのフィルタリング：\n");

  fseek(fd,(DCM*0)+enum_hashtriplet(pass[2], pass[3], pass[4])*WIDTH, SEEK_SET);
  fread(bin_vector1, WIDTH, 1, fd); // ハッシュの2-4バイト目に関連付けられたベクタを読み込む。

  len = count_vector_bits(bin_vector1);
  printf("4つのベクタのうち1つのみ：\t%d 個の平文のペア（占有率は %0.2f%% ）\n", len, len*100.0/9025.0);

  fseek(fd,(DCM*1)+enum_hashtriplet(pass[4], pass[5], pass[6])*WIDTH, SEEK_SET);
  fread(temp_vector, WIDTH, 1, fd); // ハッシュの4-6バイト目に関連付けられたベクタを読み込む。
  merge(bin_vector1, temp_vector);  // 最初のベクタに結合する。

  len = count_vector_bits(bin_vector1);
  printf("ベクタ1と2は結合済み：\t%d 個の平文のペア（占有率は %0.2f%% ）\n", len, len*100.0/9025.0);

  fseek(fd,(DCM*2)+enum_hashtriplet(pass[6], pass[7], pass[8])*WIDTH, SEEK_SET);
  fread(temp_vector, WIDTH, 1, fd); // ハッシュの6-8バイト目に関連付けられたベクタを読み込む。
  merge(bin_vector1, temp_vector);  // 最初の2つのベクタに結合する。

  len = count_vector_bits(bin_vector1);
  printf("最初の3つのベクタは結合済み：\t%d 個の平文のペア（占有率は %0.2f%% ）\n", len, len*100.0/9025.0);

  fseek(fd,(DCM*3)+enum_hashtriplet(pass[8], pass[9],pass[10])*WIDTH, SEEK_SET);
  fread(temp_vector, WIDTH, 1, fd); // ハッシュの8-10バイト目に関連付けられたベクタを読み込む。
  merge(bin_vector1, temp_vector);  // 他のベクタに結合する。

  len = count_vector_bits(bin_vector1);
  printf("4つのベクタすべては結合済み：\t%d 個の平文のペア（占有率は %0.2f%% ）\n", len, len*100.0/9025.0);

  printf("最初の2バイトに対して考えられる平文のペア：\n");
  print_vector(bin_vector1);

  printf("\n最後の2文字に対して可能\な平文のフィルタリング：\n");

  fseek(fd,(DCM*4)+enum_hashtriplet(pass[2], pass[3], pass[4])*WIDTH, SEEK_SET);
  fread(bin_vector2, WIDTH, 1, fd); // ハッシュの2-4バイト目に関連付けられたベクタを読み込む。

  len = count_vector_bits(bin_vector2);
  printf("4つのベクタのうち1つのみ：:\t%d 個の平文のペア（占有率は %0.2f%% ）\n", len, len*100.0/9025.0);

  fseek(fd,(DCM*5)+enum_hashtriplet(pass[4], pass[5], pass[6])*WIDTH, SEEK_SET);
  fread(temp_vector, WIDTH, 1, fd); // ハッシュの4-6バイト目に関連付けられたベクタを読み込む。
  merge(bin_vector2, temp_vector);  // 最初のベクタに結合する。

  len = count_vector_bits(bin_vector2);
  printf("ベクタ1と2は結合済み：\t%d 個の平文のペア（占有率は %0.2f%% ）\n", len, len*100.0/9025.0);

  fseek(fd,(DCM*6)+enum_hashtriplet(pass[6], pass[7], pass[8])*WIDTH, SEEK_SET);
  fread(temp_vector, WIDTH, 1, fd); // ハッシュの6-8バイト目に関連付けられたベクタを読み込む。
  merge(bin_vector2, temp_vector);  // 最初の2つのベクタに結合する。

  len = count_vector_bits(bin_vector2);
  printf("最初の3つのベクタは結合済み：\t%d 個の平文のペア（占有率は %0.2f%% ）\n", len, len*100.0/9025.0);

  fseek(fd,(DCM*7)+enum_hashtriplet(pass[8], pass[9],pass[10])*WIDTH, SEEK_SET);
  fread(temp_vector, WIDTH, 1, fd); // ハッシュの8-10バイト目に関連付けられたベクタを読み込む。
  merge(bin_vector2, temp_vector);  // その他のベクタに結合する。

  len = count_vector_bits(bin_vector2);
  printf("4つのベクタすべては結合済み：\t%d 個の平文のペア（占有率は %0.2f%% ）\n", len, len*100.0/9025.0);

  printf("最後の2バイトについて考えられる平文のペア：\n");
  print_vector(bin_vector2);

  printf("確率ベクタを作成中です...\n");
  for(i=0; i < 9025; i++) { // 考えられる最初の2つの平文バイトを検索する。
    if(get_vector_bit(bin_vector1, i)==1) {;
      prob_vector1[0][pv1_len] = i / 95;
      prob_vector1[1][pv1_len] = i - (prob_vector1[0][pv1_len] * 95);
      pv1_len++;
    }
  }
  for(i=0; i < 9025; i++) { // 考えられる最後の2つの平文バイトを検索する。
    if(get_vector_bit(bin_vector2, i)) {
      prob_vector2[0][pv2_len] = i / 95;
      prob_vector2[1][pv2_len] = i - (prob_vector2[0][pv2_len] * 95);
      pv2_len++;
    }
  }

  printf("残る %d の可能\性を解読しています...\n", pv1_len*pv2_len);
  for(i=0; i < pv1_len; i++) {
    for(j=0; j < pv2_len; j++) {
      plain[0] = prob_vector1[0][i] + 32;
      plain[1] = prob_vector1[1][i] + 32;
      plain[2] = prob_vector2[0][j] + 32;
      plain[3] = prob_vector2[1][j] + 32;
      plain[4] = 0;
      if(strcmp(crypt(plain, "je"), pass) == 0) {
        printf("パスワード：  %s\n", plain);
        i = 31337;
        j = 31337;
      }
    }
  }
  if(i < 31337)
    printf("パスワードの salt が 'je' でないか、長さが 4 桁ではありません。\n");

  fclose(fd);
}
