#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ID_LEN 40
#define MAX_DESC_LEN 500

/* メッセージを表示して終了する。 */
void barf(char *message, void *extra) {
   printf(message, extra);
   exit(1);
}

/* データベース中の製品詳細を更新する関数（簡潔にするため、実際には更新していない） */
void update_product_description(char *id, char *desc)
{
   char product_code[6], description[MAX_DESC_LEN];

   printf("[DEBUG]: description は %p にあります。\n", description);
   strncpy(description, desc, MAX_DESC_LEN);
   strcpy(product_code, id);

   printf("製品 #%s を詳細 \'%s\' で更新します。\n", product_code, desc);
   // データベースの更新
}

int main(int argc, char *argv[], char *envp[])
{
  int i;
  char *id, *desc;

  if(argc < 2)
     barf("使用方法： %s ＜製品コード＞ ＜詳細＞\n", argv[0]);
  id = argv[1];   // 製品コード - データベース中の更新対象製品コード
  desc = argv[2]; // desc - 更新する製品詳細


  if(strlen(id) > MAX_ID_LEN) // idはMAX_ID_LENバイト未満でなければならない。
     barf("致命的なエラー： 製品コードは %u バイト未満でないといけません。\n", (void *)MAX_ID_LEN);

  for(i=0; i < strlen(desc)-1; i++) { // descは印字可能なバイトのみが許される。
     if(!(isprint(desc[i])))
        barf("致命的なエラー： 詳細は印字可能なバイトでのみ指定できます。\n", NULL);
  }

  // スタックメモリのクリア（セキュリティ）
  // 第1引数と第2引数以外の引数をクリア
  memset(argv[0], 0, strlen(argv[0]));
  for(i=3; argv[i] != 0; i++)
    memset(argv[i], 0, strlen(argv[i]));
  // 環境変数をすべてクリア
  for(i=0; envp[i] != 0; i++)
    memset(envp[i], 0, strlen(envp[i]));

//  printf("[DEBUG]: desc は %p にあります。\n", desc);

  update_product_description(id, desc); // データベースの更新
}
