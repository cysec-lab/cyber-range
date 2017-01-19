#!/bin/bash

CLIENT_NUM=(311 312 313 321 322 323 331 332 333 341 342 343)
WEB_NUM=(314 324 334 344)
VYOS_NUM=(221 222 223 224)

VM=(${CLIENT_NUM[@]} ${WEB_NUM[@]} ${VYOS_NUM[@]})

for i in ${VM[@]}
do
	./delete_vm.sh $i &
done

