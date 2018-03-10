#!/bin/bash

start_time=`date +%s`

#STUDENTS_PER_GROUP=4
#GROUP_NUM=6

VG_NAME='VolGroup'
#VYOS_NUM=(511 521 531 541 551 561)
WEB_NUM=(512 522 532 542 552 562)
CLIENT_NUM=(513 514 515 516 523 524 525 526 533 534 535 536 543 544 545 546 553 554 555 556 563 564 565 566)


#for num in ${VYOS_NUM[@]}; do
#    $WORK_DIR/delete.sh $num
#done

for num in ${WEB_NUM[@]}; do
    $WORK_DIR/delete.sh $num
done

for num in ${CLIENT_NUM[@]}; do
    $WORK_DIR/delete.sh $num
done

end_time=`date +%s`

time=$((end_time - start_time))
echo $time
