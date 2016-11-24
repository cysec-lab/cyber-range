#include <stdio.h> 
#include <stdlib.h>
#include <string.h> 
#include <fcntl.h> 
#include <sys/stat.h> 
#include "hacking.h"
#define FILENAME "/var/notes"

int print_notes(int, int, char *);   // メモの出力関数
int find_user_note(int, int);        // 特定ユーザのメモをファイルから検索する関数
int search_note(char *, char *);     // キーワード検索関数
void fatal(char *);                  // 致命的エラーを取り扱う関数

int main(int argc, char *argv[]) {
   int userid, printing=1, fd; // ファイル記述子
   char searchstring[100];

   if(argc > 1)                        // コマンドライン引数が指定されている場合、
      strcpy(searchstring, argv[1]);   //   検索文字列として扱う。
   else                                // そうでない場合、
      searchstring[0] = 0;             //   検索文字列を空に設定する。

   userid = getuid(); 
   fd = open(FILENAME, O_RDONLY);  // リードオンリーでファイルをオープンする。
   if(fd == -1)
      fatal("main()内、ファイルの読み込みオープンでエラーが発生しました。");

   while(printing) 
      printing = print_notes(fd, userid, searchstring);
   printf("-------[ メモの終わり ]-------\n"); 
   close(fd);
}

// 特定のユーザでオプショナルの検索文字列に適合するメモを
// 表示する関数；
// ファイルの終端に到達した場合には0、まだメモがある場合には1を返す。
int print_notes(int fd, int uid, char *searchstring) {
   int note_length; 
   char byte=0, note_buffer[100];

   note_length = find_user_note(fd, uid); 
   if(note_length == -1)  // ファイルの終端に到達した場合、
      return 0;           //   0を返す。

   read(fd, note_buffer, note_length); // メモのデータを読み込む。
   note_buffer[note_length] = 0;       // 文字列を終了させる。

   if(search_note(note_buffer, searchstring)) // 検索文字列が見つかった場合、
      printf(note_buffer);                    //   メモを出力する。
   return 1;
}

// 特定のuidの次のメモを検索する関数；
// ファイルの終端に到達した場合、-1を返す。
// そうでない場合、検索されたメモの長さを返す。
int find_user_note(int fd, int user_uid) {
   int note_uid=-1; 
   unsigned char byte; 
   int length;

   while(note_uid != user_uid) {  // user_uidのメモが検索できる限り繰り返す
      if(read(fd, &note_uid, 4) != 4) // uidデータを読み込む。
         return -1; // 4バイト読み込めなかった場合、EOFを返す。
      if(read(fd, &byte, 1) != 1) // 改行の区切り文字を読み込む。
         return -1;

      byte = length = 0; 
      while(byte != '\n') {  // 行末までのバイト数を取得する。
         if(read(fd, &byte, 1) != 1) // 1バイト読み込む。
            return -1;      // 読み込めなかった場合、EOFコードを返す。
         length++;
      }
   }
   lseek(fd, length * -1L, SEEK_CUR); // lengthバイトだけ、ファイルを巻き戻す。

   printf("[DEBUG] uid %dの%dバイトのメモを見つけました。\n", note_uid, length); 
   return length;
}

// 特定のキーワードに対するメモを検索する関数；
// 検索できた場合は1を返し、検索できなかった場合は0を返す。
int search_note(char *note, char *keyword) {
   int i, keyword_length, match=0;

   keyword_length = strlen(keyword); 
   if(keyword_length == 0)  // 検索文字列がない場合、
      return 1;             //   常に「検索できた」ことにする。

   for(i=0; i < strlen(note); i++) { // メモの各バイトごとに繰り返す。
      if(note[i] == keyword[match])  // バイトがキーワードと合致した場合、
         match++;   // 次のバイトのチェック準備を行う。
      else {        //   そうでない場合、
         if(note[i] == keyword[0]) // 該当バイトがキーワードの最初のバイトと合致した場合、
            match = 1;  // 1からマッチングを開始する。
         else
            match = 0;  // そうでない場合は0を設定する。
      } 
      if(match == keyword_length) // 完全に合致した場合、
         return 1;   // 合致した旨を返す。
   }
   return 0;  // 合致しなかった旨を返す。
}
