#!/usr/bin/env bash

display_usage() {
        echo -e "\nUsage:\n curl_gluster [bucket_name] [file_name] \n"
        echo "curl_gluster sends a file to a gluster bucket."
        echo -e "\nGluster end point is stored in env GLUSTER_ENDPOINT"

}

if [ -z "$GLUSTER_ENDPOINT" ]; then
    hostname='127.0.0.1'
else
    hostname=$GLUSTER_ENDPOINT
fi

# check whether user had supplied -h or --help . If yes display usage
if [[ ( "$1" == "--help") ||  "$1" == "-h" ]]
then
    display_usage
    exit 0
fi

if [ $# -ne 2 ]
then
    echo -e "Two arguments requires.\n"
    display_usage
    exit 1
fi

filename=$2
parts=(${filename//./ })
newfilename=${parts[0]}_$(date +%s%N).${parts[1]}

echo "Sending file $2 to $1 on $hostname"

curl -v -X PUT  -H "X-Auth-Token: kcfa2ec3104034b6d9b3b9b" -T $2    http://$hostname:8080/v1/AUTH_gv0/$1/$newfilename
