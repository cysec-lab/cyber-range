#include <libnet.h>
#include <pcap.h>
#include "hacking.h"

#define MAX_EXISTING_PORTS 30

void caught_packet(u_char *, const struct pcap_pkthdr *, const u_char *);
int set_packet_filter(pcap_t *, struct in_addr *, u_short *);

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
   int network, i;
   struct data_pass critical_libnet_data;
   u_short existing_ports[MAX_EXISTING_PORTS];
   
   if((argc < 2) || (argc > MAX_EXISTING_PORTS+2)) {
      if(argc > 2)
         printf("追跡対象の既存ポートを %d 個までに制限しました。\n", MAX_EXISTING_PORTS);
      else
         printf("使用方法： %s ＜シュラウド対象IPアドレス＞ ［既存ポート ...］[existing ports...]\n", argv[0]);
      exit(0);
   }

   target_ip = libnet_name_resolve(argv[1], LIBNET_RESOLVE);
   if (target_ip == -1)
      fatal("対象アドレスが不正です。");

   for(i=2; i < argc; i++)
      existing_ports[i-2] = (u_short) atoi(argv[i]);

   existing_ports[argc-2] = 0;

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

   set_packet_filter(pcap_handle, (struct in_addr *)&target_ip, existing_ports);

   pcap_loop(pcap_handle, -1, caught_packet, (u_char *)&critical_libnet_data);
   pcap_close(pcap_handle);
}

/* target_ipに対する確立されたTCPコネクションを検索するためのパケットフィルタを設定する */
int set_packet_filter(pcap_t *pcap_hdl, struct in_addr *target_ip, u_short *ports) {
   struct bpf_program filter;
   char *str_ptr, filter_string[90 + (25 * MAX_EXISTING_PORTS)];
   int i=0;

   sprintf(filter_string, "dst host %s and ", inet_ntoa(*target_ip)); // 対象となるIP 
   strcat(filter_string, "tcp[tcpflags] & tcp-syn != 0 and tcp[tcpflags] & tcp-ack = 0");

   if(ports[0] != 0) { // 少なくとも1つの既存ポートが存在する場合
      str_ptr = filter_string + strlen(filter_string);
      if(ports[1] == 0) // 既存ポートが1つだけ存在する
         sprintf(str_ptr, " and not dst port %hu", ports[i]);
      else { // 既存ポートが複数存在する
         sprintf(str_ptr, " and not (dst port %hu", ports[i++]);
         while(ports[i] != 0) {
            str_ptr = filter_string + strlen(filter_string);
            sprintf(str_ptr, " or dst port %hu", ports[i++]);
         }
         strcat(filter_string, ")");
      }
   }
   printf("DEBUG: filter string is \'%s\'\n", filter_string);
   if(pcap_compile(pcap_hdl, &filter, filter_string, 0, 0) == -1)
      fatal("pcap_compileに失敗しました。");

   if(pcap_setfilter(pcap_hdl, &filter) == -1)
      fatal("pcap_setfilterに失敗しました。");
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

   libnet_build_ip(LIBNET_TCP_H,      // IPヘッダを除いたパケットのサイズ
      IPTOS_LOWDELAY,                 // IP tos
      libnet_get_prand(LIBNET_PRu16), // IP ID （乱数化）
      0,                              // 断片化
      libnet_get_prand(LIBNET_PR8),   // TTL （乱数化）
      IPPROTO_TCP,                    // トランスポートプロトコル
      *((u_long *)&(IPhdr->ip_dst)),  // 送信元IP（宛先であることを詐称する）
      *((u_long *)&(IPhdr->ip_src)),  // 宛先IP（送信元に送り返す）
      NULL,                           // ペイロード(なし）
      0,                              // ペイロード長
      passed->packet);                // パケットヘッダメモリ

   libnet_build_tcp(htons(TCPhdr->th_dport),// 送信元TCPポート（宛先であることを詐称する）
      htons(TCPhdr->th_sport),        // 宛先TCPポート（送信元に送り返す）
      htonl(TCPhdr->th_ack),          // シーケンス番号（以前のACKを使用する）
      htonl((TCPhdr->th_seq) + 1),    // 確認応答（ACK）番号（SYNのシーケンス番号 + 1）
      TH_SYN | TH_ACK,                // コントロールフラグ（RSTフラグのみ設定）
      libnet_get_prand(LIBNET_PRu16), // ウィンドウサイズ （乱数化）
      0,                              // 至急ポインタ
      NULL,                           // ペイロード(なし）
      0,                              // ペイロード長
      (passed->packet) + LIBNET_IP_H);// パケットヘッダメモリ

   if (libnet_do_checksum(passed->packet, IPPROTO_TCP, LIBNET_TCP_H) == -1)
      libnet_error(LIBNET_ERR_FATAL, "can't compute checksum\n");

   bcount = libnet_write_ip(passed->libnet_handle, passed->packet, LIBNET_IP_H+LIBNET_TCP_H);
   if (bcount < LIBNET_IP_H + LIBNET_TCP_H)
      libnet_error(LIBNET_ERR_WARNING, "Warning: Incomplete packet written.");
   printf("bing!\n");
}
