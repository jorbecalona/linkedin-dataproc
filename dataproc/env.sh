#!/usr/local/bin/bash

PROJECT=linkedin-dataproc
BUCKET_NAME=linkedin-dataproc
CLUSTER=linkedin-dataproc-spark
ZONE=us-east1-b
CHROME_PROFILE_DIR="$HOME/Library/Application Support/Google/Chrome/Default/"

alias dataproc-cluster-init="gcloud dataproc clusters create $CLUSTER \
    --subnet default \
    --zone $ZONE \
    --single-node \
    --master-machine-type n1-standard-4 \
    --master-boot-disk-size 500 \
    --image-version 1.3-deb9 \
    --project $PROJECT \
    --initialization-actions gs://dataproc-initialization-actions/datalab/datalab.sh"

# socks proxy over ssh tunnel
alias dataproc-ssh-tunnel="gcloud compute ssh ${CLUSTER}-m \
  --project $PROJECT \
  --zone=$ZONE \
  --ssh-flag='-D 1080' \
  --ssh-flag='-N' \
  --ssh-flag='-n'"

# Open chrome with socks proxy
alias dataproc-chrome-socks="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
   http://linkedin-dataproc-spark-m:8080 \
  --proxy-server='socks5://localhost:1080' \
  --host-resolver-rules='MAP * 0.0.0.0, EXCLUDE localhost' \
  --user-data-dir='/tmp/' \
  --user-data-dir=$CHROME_PROFILE_DIR"

alias dataproc-ssh="gcloud compute ssh --zone=$ZONE ${CLUSTER}-m"

# echo "dataproc-cluster-init starts cluster"
# echo "dataproc-ssh-tunnel tunnel ports for datalab notebook proxy"
# echo "dataproc-chrome-socks starts chrome with proxy. navigate to ${CLUSTER}-m:8080 for notebook"

echo "Starting Cluster. This may take up to 15 minutes"
# dataproc-cluster-init
echo "Starting SSH tunnel and Chrome Socks Dataproc Interface"
echo "To terminate session, press Ctrl + C and quit the dataproc chrome browser"
dataproc-chrome-socks &
dataproc-ssh-tunnel
