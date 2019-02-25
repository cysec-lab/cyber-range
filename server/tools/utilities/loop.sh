#!/bin/bash
# IO負荷が重くなるとFULLクローンを失敗することがあるので書き込み処理をループさせる

if [ $# -ne 4 ]; then
    echo "[Clone type] [テンプレートVM番号] [作成するVMの開始数字] [作成するVMの終了番号]"
    echo "$0 full 900 950 980"
    echo "900のテンプレートVMを950~980にクローンする"
    exit 1
fi

CLONE_TYPE=$1
TEMPLATE_VM_NUM=$2
START_NUM=$3
END_NUM=$4

CONF_DIR='/etc/pve/qemu-server'

# time measurement start
start_time=`date +%s`

# CLONE_TYPEのチェック
# TARGET_STRAGEを指定しているが利用していない
# TARGET_STRAGEはlocal-zfsに決め打ちしている
if [ "$CLONE_TYPE" = 'zfs' ]; then
    TARGET_STRAGE='local-zfs' # zfs clone target strage
elif [ "$CLONE_TYPE" = 'full' ]; then
    TARGET_STRAGE='local'     # full clone target strage
else
    echo 'invalid data'
    echo 'clone type is zfs or full'
    exit 1
fi

# テンプレートVMの有無をチェック
if [ ! -e "$CONF_DIR/${TEMPLATE_VM_NUM}.conf" ]; then
    echo "${TEMPLATE_VM_NUM}番のテンプレートVMは存在しません"
    exit 1
fi

## 作成VMのレンジチェック
loop_flg=1
while [ $loop_flg = 1 ]; do
	loop_flg=0
	# VMのクローン
	bash ./clone_many_same_vms.sh $CLONE_TYPE $TEMPLATE_VM_NUM $START_NUM $END_NUM

	# VMクローン成否チェック
	for ((new_vm_num=$START_NUM; new_vm_num <= $END_NUM; new_vm_num++)); do
	    if [ ! -e "$CONF_DIR/${new_vm_num}.conf" ]; then

	        # FULLクローンできなかったVMが存在する
		loop_flg=1
	    fi
	done
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time

