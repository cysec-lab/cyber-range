#!/bin/bash
# http://d.hatena.ne.jp/iamsandman/20110510/1304984590

vyatt_sbin=/opt/vyata/sbin

wr=$vyatt_sbin/vyatta-cfg-cmd-wrapper

opt_cmd=$1
shift
cmdline=$*

cfg_stdin() {
    while read line
    do
        eval $wr "$line"
    done
}

cfg_cmdline() {
    eval $wr $cmdline
}

./etc/bash_compietion

$wr begin

if [ "${opt_cmd}" = "-c" ] then
    cfg_cmdline
else
    cfg_stdin
fi

$wr commit 

$wr end
