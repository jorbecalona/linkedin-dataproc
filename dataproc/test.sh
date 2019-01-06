#!/usr/local/bin/bash

echo testing
source "env.conf"

echo $PROJECT

export CHROME_PATH=${CHROME_PATH:-"/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"}
echo $CHROME_PATH

if [[ -e "env.conf" ]]; then
    source "env.conf"
    PROJECT=${PROJECT:?"PROJECT must be defined in env.conf"}
    BUCKET=${BUCKET:?"BUCKET must be defined in env.conf"}
    CLUSTER=${CLUSTER:?"CLUSTER must be defined in env.conf"}
    ZONE=${ZONE:?"ZONE must be defined in env.conf"}
fi

case "$1" in
all)
    cluster-init
    cluster-datalab
    ;;
start | up | init)
    cluster-init
    ;;
teardown | down | delete | stop)
    cluster-teardown
    ;;
datalab | pySpark | notebook)
    cluster-datalab
    ;;
ssh)
    cluster-ssh
    ;;
*)
    echo "Usage: $0 {all|start|teardown|datalab|ssh}"
    ;;
esac

open -n "Google Chrome" "http://"${CLUSTER_MASTER_URI}":8080" --args --proxy-server='socks5://localhost:1080' --host-resolver-rules='MAP * 0.0.0.0, EXCLUDE localhost' --user-data-dir='/tmp/' --user-data-dir="$HOME/Library/Application Support/Google/Chrome/Default/"

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    --proxy-server="socks5://localhost:${PORT}" \
    --user-data-dir=/tmp/${HOSTNAME}

"$(echo $CHROME_PATH)" http://"${CLUSTER_MASTER_URI}":8080 \
    --proxy-server='socks5://localhost:1080' \
    --host-resolver-rules='MAP * 0.0.0.0, EXCLUDE localhost' \
    --user-data-dir='/tmp/' \
    --user-data-dir=$CHROME_PROFILE_DIR

$CHROME_PATH http://"${CLUSTER_MASTER_URI}":8080 \
    --proxy-server='socks5://localhost:1080' \
    --host-resolver-rules='MAP * 0.0.0.0, EXCLUDE localhost' \
    --user-data-dir=$CHROME_PROFILE_DIR

echo "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" http://$CLUSTER_MASTER_URI:8080 \
    --proxy-server='socks5://localhost:1080' \
    --host-resolver-rules='MAP * 0.0.0.0, EXCLUDE localhost' \
    --user-data-dir='/tmp/' \
    --user-data-dir=$CHROME_PROFILE_DIR

cmd=(/Applications/Google Chrome.app/Contents/MacOS/Google Chrome --option --)
file1="http://$CLUSTER_MASTER_URI:8080"
cmd=("${cmd[@]}" "$file1" "$file2")
"${cmd[@]}"

datalab_path="http://$CLUSTER_MASTER_URI:8080"
set -- "$CHROME_PATH" "$datalab_path"
set "$@" --proxy-server='socks5://localhost:1080' \
            --user-data-dir="$CHROME_PROFILE_DIR" --
# set -- "$@" "$datalab_path"
"$@"

    "$@"
    set -- CHROME_PATH'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' \
            --proxy-server='socks5://localhost:1080' \
            --user-data-dir="$CHROME_PROFILE_DIR" --
    set -- "$@" "$http://$CLUSTER_MASTER_URI:8080"
    "$@"

    code='CHROME_PATH' 
    # set -- $CHROME_PATH \
    #     --proxy-server='socks5://localhost:1080' \
    #     --user-data-dir="$CHROME_PROFILE_DIR" --
    set -- "$@" "$datalab_path"

    dataproc-util "$@"



    set -- $chrome_bin \
            --proxy-server='socks5://localhost:1080' \
            --user-data-dir="$CHROME_PROFILE_DIR" --
    set -- "$@" "$datalab_path"
    chrome_command="$@"
    echo ${chrome_command}
    # chrome_bin=$CHROME_PATH
    echo ${CHROME_PATH} 
    CHROME_PATH=("${CHROME_PATH[@]}" \
        "--proxy-server='socks5://localhost:1080'" \
        "--user-data-dir=$CHROME_PROFILE_DIR" --)
    echo "${CHROME_PATH[@]}"
    CHROME_PATH=("${CHROME_PATH[@]}" "${datalab_path}")
    echo "${CHROME_PATH[@]}"




# echo "dataproc-_cluster-init starts cluster"
# echo "dataproc-ssh-tunnel tunnel ports for datalab notebook proxy"
# echo "dataproc-chrome-socks starts chrome with proxy. navigate to ${CLUSTER}-m:8080 for notebook"

# echo "Starting Cluster. This may take up to 15 minutes"
# dataproc-_cluster-init
# echo "Starting SSH tunnel and Chrome Socks Dataproc Interface"
# echo "To terminate session, press Ctrl + C and quit the dataproc chrome browser"
# dataproc-chrome-socks &
# dataproc-ssh-tunnel




# function dataproc-makealiases() {
#     alias dataproc-_cluster-init="gcloud dataproc clusters create $CLUSTER \
#             --subnet default \
#             --zone $ZONE \
#             --bucket $BUCKET
#             --single-node \
#             --master-machine-type n1-standard-4 \
#             --master-boot-disk-size 500 \
#             --image-version 1.3-deb9 \
#             --project $PROJECT \
#             --initialization-actions gs://dataproc-initialization-actions/datalab/datalab.sh"

#     alias dataproc-ssh-tunnel="gcloud compute ssh ${CLUSTER}-m \
#         --project $PROJECT \
#         --zone=$ZONE \
#         --ssh-flag='-D 1080' \
#         --ssh-flag='-N' \
#         --ssh-flag='-n'"

#     alias dataproc-chrome-socks="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
#         http://linkedin-dataproc-spark-m:8080 \
#         --proxy-server='socks5://localhost:1080' \
#         --host-resolver-rules='MAP * 0.0.0.0, EXCLUDE localhost' \
#         --user-data-dir='/tmp/' \
#         --user-data-dir=$CHROME_PROFILE_DIR"
#     alias dataproc-ssh="gcloud compute ssh --zone=$ZONE ${CLUSTER}-m"
# }