#define _XOPEN_SOURCE
#include <unistd.h>
#include <stdio.h>

/* メッセージを出力して終了する。 */
void barf(char *message, char *extra) {
   printf(message, extra);
   exit(1);
}

/* 辞書攻撃を行うプログラムの例 */
int main(int argc, char *argv[]) {
   FILE *wordlist;
   char *hash, word[30], salt[3];
   if(argc < 2)
      barf("使用方法： %s ＜単語一覧が格納されたファイル＞ ＜パスワードのハッシュ値＞\n", argv[0]);

   strncpy(salt, argv[2], 2); // ハッシュの最初の2バイトはsalt値である。
   salt[2] = '\0';  // 文字列を終端する。

   printf("salt値は \'%s\' です。\n", salt);

   if( (wordlist = fopen(argv[1], "r")) == NULL) // 単語一覧が格納されたファイルをオープンする。
      barf("致命的なエラー： ファイル \'%s\' をオープンできません。\n", argv[1]);

   while(fgets(word, 30, wordlist) != NULL) { // 各単語を読み込む
      word[strlen(word)-1] = '\0'; // 終端の'\n'バイトを除去する。
      hash = crypt(word, salt); // salt値を用いて単語のハッシュ値を算出する。
      printf("テスト中の単語：   %-30s ==> %15s\n", word, hash);
      if(strcmp(hash, argv[2]) == 0) { // ハッシュ値がマッチした場合、
         printf("\"%s\" というハッシュ値は、", argv[2]);
         printf("\"%s\" という平文のパスワードから作り出されたものです。\n", word);
         fclose(wordlist);
         exit(0);
      }
   }
   printf("指定された単語一覧から平文のパスワードを見つけることができませんでした。\n");
   fclose(wordlist);
}
