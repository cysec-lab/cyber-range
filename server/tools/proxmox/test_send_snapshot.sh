#!/bin/bash

start_time=`date +%s`

for ((i=8;i<28;i++)); do
	num=$((800+i))
	#./clone_vm.sh $num 954 WindowsTemplate local-tvm 5
	./send_snapshot.sh $num tvmpool rpool
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time
