#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <time.h>
#include <stdlib.h>
#include "hacking.h"

#define DATAFILE "/var/chance.data" // ユーザデータを格納するファイル

// ユーザに関する情報を格納するためのユーザ構造体
struct user {
   int uid;
   int credits;
   int highscore;
   char name[100];
   int (*current_game) ();
};

// 関数プロトタイプ
int get_player_data();
void register_new_player();
void update_player_data();
void show_highscore();
void jackpot();
void input_name();
void print_cards(char *, char *, int);
int take_wager(int, int);
void play_the_game();
int pick_a_number();
int dealer_no_match();
int find_the_ace();
void fatal(char *);

// 大域変数
struct user player;      // プレイヤーの構造体

int main() {
   int choice, last_game;

   srand(time(0)); // 乱数発生器に種として現在時刻を与える。
   
   if(get_player_data() == -1)  // プレイヤーのデータをファイルから読み込む。
      register_new_player();    // データがなければ新たなプレイヤーを登録する。

   while(choice != 7) {
      printf("-=[ 運試しゲーム：メニュー ]=-\n");
      printf("1 - 数字選びゲームを行う\n");
      printf("2 - 数字よけゲームを行う\n");
      printf("3 - エースを探せゲームを行う\n");
      printf("4 - 現在のハイスコアを見る\n");
      printf("5 - ユーザ名を変更する\n");
      printf("6 - 持ち金を100クレジットにリセットする\n");
      printf("7 - 終了する\n");
      printf("[名前： %s]\n", player.name);
      printf("[手元には %u クレジットあります。] ->  ", player.credits);
      scanf("%d", &choice);

      if((choice < 1) || (choice > 7))
         printf("\n[!!] メニューに %d はありません。\n\n", choice);
      else if (choice < 4) {          // そうでない場合、何らかのゲームが選択された。
            if(choice != last_game) { // 関数ポインタが設定されていない場合、
               if(choice == 1)        // 選択されたゲームを指すよう設定し、
                  player.current_game = pick_a_number;   
               else if(choice == 2)                     
                  player.current_game = dealer_no_match;
               else
                  player.current_game = find_the_ace;
               last_game = choice;   // last_gameを設定する。
            }
            play_the_game();         // ゲームを開始する。
         }
      else if (choice == 4)
         show_highscore();
      else if (choice == 5) {
         printf("\nユーザ名を変更します。\n");
         printf("新しいユーザ名を入力してください： ");
         input_name();
         printf("あなたのユーザ名は変更されました。\n\n");
      }
      else if (choice == 6) {
         printf("\nあなたの持ち金は100クレジットにリセットされました。\n\n");
         player.credits = 100;
      }
   }
   update_player_data();
   printf("\n遊んでいただき、ありがとうございました。 それではまた！\n");
}

// この関数は、ファイルから現在のuidに基づき、プレイヤーのデータを
// 読み込む。　現在のuidのプレイヤーデータが見つからない場合、
// -1を返す。
int get_player_data() { 
   int fd, uid, read_bytes;
   struct user entry;

   uid = getuid();

   fd = open(DATAFILE, O_RDONLY);
   if(fd == -1) // ファイルをオープンできない。　おそらくファイルが存在していない。
      return -1; 
   read_bytes = read(fd, &entry, sizeof(struct user));    // 最初のかたまりを読み込む。
   while(entry.uid != uid && read_bytes > 0) { // 正しいuidが見つかるまで繰り返す。
      read_bytes = read(fd, &entry, sizeof(struct user)); // 読み込みを続ける。
   }
   close(fd); // ファイルをクローズする。
   if(read_bytes  < sizeof(struct user)) // これはファイルの終端に到達したことを意味している。
      return -1;
   else
      player = entry; // プレイヤー構造体にエントリーをコピーする。
   return 1;          // 正常に処理できたことを返す。
}

// これは新たなユーザを登録する関数である。
// これによって、新たなプレイヤーのアカウントが作成され、ファイルの末尾に追加される。
void register_new_player()  { 
   int fd;

   printf("-=-={ 新規プレイヤーの登録 }=-=-\n");
   printf("ユーザ名を入力してください： ");
   input_name();

   player.uid = getuid();
   player.highscore = player.credits = 100;

   fd = open(DATAFILE, O_WRONLY|O_CREAT|O_APPEND, S_IRUSR|S_IWUSR);
   if(fd == -1)
      fatal("register_new_player()内で、ファイルのオープン中にエラーが発生しました。");
   write(fd, &player, sizeof(struct user));
   close(fd);

   printf("\n%sさん、運試しゲームにようこそ！\n", player.name);
   printf("あなたには%uクレジットが与えられます。\n", player.credits);
}

// この関数によって現在のプレイヤーのデータがファイルに書き込まれる。
// これは主にゲーム終了後にクレジット情報を更新するために用いられる。
void update_player_data() {
   int fd, i, read_uid;
   char burned_byte;

   fd = open(DATAFILE, O_RDWR);
   if(fd == -1) // ここでオープンに失敗した場合、何かまずいことが起こっている。
      fatal("update_player_data()内で、ファイルのオープン中にエラーが発生しました。");
   read(fd, &read_uid, 4);          // 最初の構造体からuidを読み込む。
   while(read_uid != player.uid) {  // 正しいuidが見つかるまで繰り返す。
      for(i=0; i < sizeof(struct user) - 4; i++)  // この構造体の残りを
         read(fd, &burned_byte, 1);               // 読み込む。
      read(fd, &read_uid, 4);       // 次の構造体からuidを読み込む。
   }
   write(fd, &(player.credits), 4);   // クレジットを更新する。
   write(fd, &(player.highscore), 4); // ハイスコアを更新する。
   write(fd, &(player.name), 100);    // ユーザ名を更新する。
   close(fd);
}

// この関数によって現在のハイスコアとそのハイスコアを獲得したユーザ名を
// 表示する。
void show_highscore() {
   unsigned int top_score = 0;
   char top_name[100];
   struct user entry;
   int fd;

   printf("\n====================| ハイスコア |====================\n");
   fd = open(DATAFILE, O_RDONLY);
   if(fd == -1)
      fatal("show_highscore()内で、ファイルのオープン中にエラーが発生しました。");
   while(read(fd, &entry, sizeof(struct user)) > 0) { // ファイルの終端まで繰り返す。
      if(entry.highscore > top_score) {   // ハイスコアがある場合、
            top_score = entry.highscore;  // そのスコアをtop_scoreに設定し、
            strcpy(top_name, entry.name); // そのユーザ名をtop_nameに設定する。
      }
   }
   close(fd);
   if(top_score > player.highscore)
      printf("ハイスコアは%sの%uです。\n", top_name, top_score);
   else
      printf("現在、あなたは%uクレジットでハイスコアとなっています！\n", player.highscore);
   printf("======================================================\n\n");
}

// この関数は数字選びゲームでジャックポットを当てた場合に呼び出される。
void jackpot() {
   printf("*+*+*+*+*+* ジャックポット *+*+*+*+*+*\n");
   printf("あなたは100クレジットのジャックポットを引き当てました！\n");
   player.credits += 100;
}

// この関数は、プレイヤー名を入力するために用いられる。
// （scanf("%s", &whatever)は最初の空白までしか読み込まないため。）
void input_name() {
   char *name_ptr, input_char='\n';
   while(input_char == '\n')    // 残った改行文字を捨て去る。
      scanf("%c", &input_char); 
   
   name_ptr = (char *) &(player.name); // name_ptr = プレイヤー名のアドレス
   while(input_char != '\n') {  // 改行文字まで繰り返し。
      *name_ptr = input_char;   // 入力文字を名前フィールドに設定する。
      scanf("%c", &input_char); // 次の文字に進む。
      name_ptr++;               // 名前のポインタをインクリメントする。
   }
   *name_ptr = 0;  // 文字列を終了させる。
}

// この関数によって、エースを探せゲームにおける3枚のカードが表示される。
// この関数は表示するメッセージ、カードの配列へのポインタ、ユーザが入力
// として選んだカードを受け取る。
// user_pickが-1である場合、選択した数字が表示される。
void print_cards(char *message, char *cards, int user_pick) {
   int i;

   printf("\n\t*** %s ***\n", message);
   printf("      \t._.\t._.\t._.\n");
   printf("カード：|%c|\t|%c|\t|%c|\n\t", cards[0], cards[1], cards[2]);
   if(user_pick == -1)
      printf(" 1 \t 2 \t 3\n");
   else {
      for(i=0; i < user_pick; i++)
         printf("\t");
      printf(" ^-- あなたの選んだカード\n");
   }
}

// この関数は、数字よけゲームとエースを探せゲームの双方で用いられる
// 賭け金の入力に用いられる。これは引数として利用可能なクレジットと
// 以前の賭け金を受け取る。以前の賭け金はエースを探せゲームの場合に
// のみ重要となる。この関数は、賭け金が大きすぎる場合や小さすぎる
// 場合に-1を返し、それ以外の場合は賭け金を返す。
int take_wager(int available_credits, int previous_wager) {
   int wager, total_wager;

   printf("あなたの%dクレジットから、どれだけを賭け金にしますか？ ", available_credits);
   scanf("%d", &wager);
   if(wager < 1) {   // 賭け金が0以上であることを確認する。
      printf("うーん。賭け金はマイナスにできません！\n");
      return -1;
   }
   total_wager = previous_wager + wager;
   if(total_wager > available_credits) {  // 利用可能なクレジットを確認する。
      printf("賭け金のトータル%dが手持ち額を超えています！\n", total_wager);
      printf("あなたの手持ちは%dクレジットです。やり直してください。\n", available_credits);
      return -1;
   }
   return wager;
}

// この関数には、現在のゲームをもう一度行えるようにするための
// ループがある。また、各ゲームの終了後に新たなクレジット総額を
// ファイルに書き込んでもいる。
void play_the_game() { 
   int play_again = 1;
   int (*game) ();
   char selection;

   while(play_again) {
      printf("\n[DEBUG] current_game pointer @ 0x%08x\n", player.current_game);
      if(player.current_game() != -1) {         // ゲームでエラーが発生せず、
         if(player.credits > player.highscore)  // 新しいハイスコアが出た場合、
            player.highscore = player.credits;  // ハイスコアを更新する。
         printf("\n手元には %u クレジットあります。\n", player.credits);
         update_player_data();                  // 新たなクレジットトータルをファイルに書き出す。
         printf("もう一度やってみますか？ (y/n)  ");
         selection = '\n';
         while(selection == '\n')               // 余分な改行を読み飛ばす。
            scanf("%c", &selection);
         if(selection == 'n')
            play_again = 0;
      }
      else               // ここに到達した場合、ゲーム中にエラーが発生したことを意味するため、
         play_again = 0; // メインメニューに戻る。
   }
}

// これは数字選びゲームで用いられる関数である。
// プレイヤーが十分なクレジットを持っていない場合、-1を返す。
int pick_a_number() { 
   int pick, winning_number;

   printf("\n####### 数字選びゲーム ######\n");
   printf("このゲームをするには10クレジットが必要となります。ルールは\n");
   printf("1から20までの数字を選ぶだけです。見事に当てることができた場合、\n");
   printf("ジャックポットとなり100クレジットが返ってきます！\n\n");
   winning_number = (rand() % 20) + 1; // 1から20までの当たり数字を決定する。
   if(player.credits < 10) {
      printf("あなたは%dクレジットしか持っていません。ゲームをするには足りません！\n\n", player.credits);
      return -1;  // ゲームをするにはクレジットが足りない。
   }
   player.credits -= 10; // 10クレジットを徴収する。
   printf("あなたのアカウントから10クレジットを徴収しました。\n");
   printf("1から20までの数字を選んでください： ");
   scanf("%d", &pick);

   printf("当たり数字は%dです。\n", winning_number);
   if(pick == winning_number)
      jackpot();
   else
      printf("残念でした。はずれです。\n");
   return 0;
}

// これは数字よけゲームで用いられる関数である。
// プレイヤーがクレジットを持っていない場合、-1を返す。
int dealer_no_match() { 
   int i, j, numbers[16], wager = -1, match = -1;

   printf("\n::::::: 数字よけゲーム :::::::\n");
   printf("このゲームはクレジットすべてを賭けることができます。\n");
   printf("ディーラーは0から99までのランダムな数字を16個決めます。\n");
   printf("16個の数字すべてが異なっていた場合、賭け金は倍になります！\n\n");
  
   if(player.credits == 0) {
      printf("クレジットがありません！\n\n");
      return -1;
   }
   while(wager == -1)
      wager = take_wager(player.credits, 0);

   printf("\t\t::: 16個の数字を決めます :::\n");
   for(i=0; i < 16; i++) {
      numbers[i] = rand() % 100; // 0から99の数字を決定する。
      printf("%2d\t", numbers[i]);
      if(i%8 == 7)               // 数字8個で改行する。
         printf("\n");
   }
   for(i=0; i < 15; i++) {       // マッチしているかどうかを検索する。
      j = i + 1;
      while(j < 16) {
         if(numbers[i] == numbers[j])
            match = numbers[i];
         j++;
      }
   }
   if(match != -1) {
      printf("ディーラーは数字%dを出していました！\n", match);
      printf("あなたは%dクレジット負けました。\n", wager);
      player.credits -= wager;
   } else {
      printf("マッチしている数字はありませんでした！あなたは%dクレジット勝ちました！\n", wager);
      player.credits += wager;
   }
   return 0;
}

// これはエースを探せで用いられる関数である。
// プレイヤーのクレジットが0である場合、-1を返す。
int find_the_ace() {
   int i, ace, total_wager;
   int invalid_choice, pick = -1, wager_one = -1, wager_two = -1;
   char choice_two, cards[3] = {'X', 'X', 'X'};

   ace = rand()%3; // エースをランダムに配置する。

   printf("******* エースを探せゲーム *******\n");
   printf("このゲームはクレジットすべてを賭けることができます。\n");
   printf("2枚のクイーンと1枚のエース、合計3枚のカードが配られます。\n");
   printf("エースを見つけることができた場合、賭け金額分の勝ちとなります。\n");
   printf("カードを選択した後、一方のクイーンの在処が明かされます。\n");
   printf("この時点で、別なカードを選択し直すか、賭け金を増やすことができます。\n\n");

   if(player.credits == 0) {
      printf("クレジットがありません！\n\n");
      return -1;
   }
   
   while(wager_one == -1) // 有効な賭け金が提示されるまで繰り返す。
      wager_one = take_wager(player.credits, 0);

   print_cards("カードを配ります", cards, -1);
   pick = -1;
   while((pick < 1) || (pick > 3)) { // 有効な選択がなされるまで繰り返す。
      printf("カードを選択してください： 1, 2, または 3： ");
      scanf("%d", &pick);
   }
   pick--; // カード番号は0から始まっているため、入力値を補正する。
   i=0;
   while(i == ace || i == pick) // 所在を明かすクイーンが見つかるまで繰り返す。
      i++;
   cards[i] = 'Q';
   print_cards("一方のクイーンの在処を明かします", cards, pick);
   invalid_choice = 1;
   while(invalid_choice) {       // 有効な選択がなされるまで繰り返す。
      printf("選んだカードを変更[c]しますか？それとも賭け金を増額[i]しますか？\n");
      printf("c か i を入力してください：  ");
      choice_two = '\n';
      while(choice_two == '\n')  // 余分な改行を読み飛ばす。
         scanf("%c", &choice_two);
      if(choice_two == 'i') {    // 賭け金を増やす。
            invalid_choice=0;    // これは有効な選択肢である。
            while(wager_two == -1)   // 有効な2つ目の賭け金が提示されるまで繰り返す。
               wager_two = take_wager(player.credits, wager_one);
         }
      if(choice_two == 'c') {    // 選択の変更
         i = invalid_choice = 0; // 有効な選択
         while(i == pick || cards[i] == 'Q') // 他のカードを見つけるまで繰り返す。
            i++;
         pick = i;                           // 選択を変更する。
         printf("あなたの選択は%dに変更されました。\n", pick+1);
      }
   }

   for(i=0; i < 3; i++) {  // すべてのカードを明かす。
      if(ace == i)
         cards[i] = 'A';
      else
         cards[i] = 'Q';
   }
   print_cards("最終結果", cards, pick);
   
   if(pick == ace) {  // プレイヤーが勝った際の処理
      printf("最初の賭け金により%dクレジット勝ち取ることができました。\n", wager_one);
      player.credits += wager_one;
      if(wager_two != -1) {
         printf("また2回目の賭け金により%dクレジットをさらに勝ち取ることができました！\n", wager_two);
         player.credits += wager_two;
      }
   } else { // プレイヤーが負けた際の処理
      printf("最初の賭け金により%dクレジットが没収されました。\n", wager_one);
      player.credits -= wager_one;
      if(wager_two != -1) {
         printf("また2回目の賭け金により%dクレジットがさらに没収されました！\n", wager_two);
         player.credits -= wager_two;
      }
   }
   return 0;
}
