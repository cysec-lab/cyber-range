#include <stdio.h> 
#include <stdlib.h>
#include <signal.h> 
/* signal.hで定義されているラベル付きシグナル
 * #define SIGHUP        1  ハングアップ 
 * #define SIGINT        2  割り込み（Ctrl-C)）
 * #define SIGQUIT       3  終了（Ctrl-\）
 * #define SIGILL        4  不正命令
 * #define SIGTRAP       5  トレース/ブレークポイントによるトラップ
 * #define SIGABRT       6  プロセスの中断
 * #define SIGBUS        7  バスエラー
 * #define SIGFPE        8  浮動小数点例外
 * #define SIGKILL       9  強制終了
 * #define SIGUSR1      10  ユーザ定義シグナル1
 * #define SIGSEGV      11  セグメンテーション違反
 * #define SIGUSR2      12  ユーザ定義シグナル2
 * #define SIGPIPE      13  読み込み相手のいないパイプへの書き込み
 * #define SIGALRM      14  alarm()によって設定されるカウントダウンアラーム
 * #define SIGTERM      15  終了（killコマンドの送信による）
 * #define SIGCHLD      17  子プロセスのシグナル
 * #define SIGCONT      18  停止している場合は再開する
 * #define SIGSTOP      19  停止（実行の中断）
 * #define SIGTSTP      20  ターミナルの停止［サスペンド］（Ctrl-Z）
 * #define SIGTTIN      21  バックグラウンドプロセスが標準入力を読み込もうとした
 * #define SIGTTOU      22  バックグラウンドプロセスが標準出力に書き込もうとした
 */ 

/* シグナルハンドラ */ 
void signal_handler(int signal) { 
   printf("シグナル%dを受け取りました。\t", signal); 
   if (signal == SIGTSTP) 
      printf("SIGTSTP (Ctrl-Z)"); 
   else if (signal == SIGQUIT) 
      printf("SIGQUIT (Ctrl-\\)"); 
   else if (signal == SIGUSR1) 
      printf("SIGUSR1"); 
   else if (signal == SIGUSR2) 
      printf("SIGUSR2"); 
   printf("\n"); 
} 

void sigint_handler(int x) { 
   printf("別のハンドラにおいてCtrl-C (SIGINT)を受け取りました。\n終了します。\n"); 
   exit(0); 
} 

int main() { 
   /* シグナルハンドラの登録 */ 
   signal(SIGQUIT, signal_handler); // signal_handler()をこれらシグナルの
   signal(SIGTSTP, signal_handler); // シグナルハンドラとして登録する
   signal(SIGUSR1, signal_handler);
   signal(SIGUSR2, signal_handler); 

   signal(SIGINT, sigint_handler);  // SIGINTのsigint_handler()を設定

   while(1) {}  // 無限ループ
} 
