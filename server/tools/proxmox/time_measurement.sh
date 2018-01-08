#!/bin/bash

if [ $# -lt 1 ]; then
    echo "./[SCRIPT_NAME] ([SCRIPT_ARGMENT])"
    echo "$0 ./script.sh "
    exit 1
fi

# extract script arguments
ARGUMENT=${@:2}

start_time=`date +%s`

$1 $ARGUMENT

end_time=`date +%s`

echo $((end_time - start_time))
