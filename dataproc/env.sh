#!/usr/local/bin/bash

# PROJECT=linkedin-dataproc
# BUCKET=linkedin-dataproc
# CLUSTER=linkedin-dataproc-spark
# ZONE=us-east1-b
# CHROME_PATH=${CHROME_PATH:-"/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"}
# CHROME_PROFILE_DIR="$HOME/Library/Application Support/Google/Chrome/Default/"
DIR="${0%/*}"
if [[ -e "$DIR/env.conf" ]]; then
    source "$DIR/env.conf"
    export PROJECT=${PROJECT:?"PROJECT must be defined in env.conf"}
    export BUCKET=${BUCKET:?"BUCKET must be defined in env.conf"}
    export CLUSTER=${CLUSTER:?"CLUSTER must be defined in env.conf"}
    export ZONE=${ZONE:?"ZONE must be defined in env.conf"}

    export CHROME_PATH='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
    export CHROME_PROFILE_DIR=${CHROME_PROFILE_DIR:-"$HOME/Library/Application Support/Google/Chrome/Default/"}
    export CLUSTER_MASTER_URI="${CLUSTER}-m"
    export CLUSTER_TYPE=${CLUSTER_TYPE:-'single-node'}
fi


# Cluster Functions
_cluster-init() {
    case "$CLUSTER_TYPE" in
        single-node)
            echo "Starting $CLUSTER_TYPE. This may take up to 15 minutes"
            gcloud dataproc clusters create "${CLUSTER}" \
                --subnet default \
                --zone "${ZONE}" \
                --bucket "${BUCKET}" \
                --single-node \
                --master-machine-type n1-standard-4 \
                --master-boot-disk-type pd-ssd \
                --master-boot-disk-size 100 \
                --image-version 1.3-deb9 \
                --project "${PROJECT}" \
                --initialization-actions 'gs://linkedin-dataproc/init-scripts/datalab.sh', \
                     'gs://linkedin-dataproc/init-scripts/user-environment.sh'
            ;;
        light-cluster)
            echo "Starting $CLUSTER_TYPE. This may take up to 15 minutes"
            gcloud dataproc clusters create "${CLUSTER}" \
                --bucket "${BUCKET}" \
                --subnet default \
                --zone "${ZONE}" \
                --master-machine-type n1-standard-4 \
                --master-boot-disk-type pd-ssd \
                --master-boot-disk-size 50 \
                --num-workers 2 \
                --worker-machine-type n1-highmem-2 \
                --worker-boot-disk-size 100 \
                --image-version 1.3-deb9 \
                --project "${PROJECT}" \
                --initialization-actions 'gs://linkedin-dataproc/init-scripts/datalab.sh', \
                    'gs://linkedin-dataproc/init-scripts/user-environment.sh'
            ;;
        *)
            echo "Usage: $0 datalab {single-node|light-cluster}"
            ;;
        esac
    


}

_cluster-teardown() {
        # Deprovision  Cluster
        echo "** Deprovisioning Cluster"
        gcloud dataproc clusters delete "${CLUSTER}"
        echo "\tCluster Deleted** \n"
}

_cluster-ssh() {
    gcloud compute ssh --zone=$ZONE ${CLUSTER_MASTER_URI}
}

# Datalab Functions
_datalab-ssh-tunnel() {
    echo "Starting SSH tunnel"
    gcloud compute ssh $CLUSTER_MASTER_URI \
        --project=$PROJECT \
        --zone=$ZONE \
        --ssh-flag='-D 1080' \
        --ssh-flag='-N' \
        --ssh-flag='-n'
}

_datalab-chrome-socks() {
    echo "Opening Datalab Interface"
    datalab_path="http://$CLUSTER_MASTER_URI:8080"
    $CHROME_PATH \
        --proxy-server='socks5://localhost:1080' \
        --host-resolver-rules='MAP * 0.0.0.0, EXCLUDE localhost' \
        --user-data-dir=$CHROME_PROFILE_DIR -- \
        http://$CLUSTER_MASTER_URI:8080
}

_datalab-init() {
    trap 'kill %1; kill %2' SIGINT
    _datalab-chrome-socks | tee 1.log | sed -e 's/^/[Chrome-Socks] /' \
        & _datalab-ssh-tunnel | tee 2.log | sed -e 's/^/[SSH-Tunnel] /' \
        & wait;
}

# Cleanup
_cleanup() {
    _cluster-teardown
    echo "** Clearing Functions"
    unset -f _cluster-init
    unset -f _cluster-teardown
    unset -f _datalab-ssh-tunnel
    unset -f _datalab-chrome-socks
    unset -f _cluster-ssh
    unset -f _datalab-init
    unset -f _cleanup
    unset -v PROJECT
    unset -v BUCKET
    unset -v CLUSTER
    unset -v ZONE
    unset -v CHROME_PATH
    unset -v CHROME_PROFILE_DIR
    unset -v CLUSTER_MASTER_URI
    echo "\tFunctions cleared ** \n"
}

# Main function
dataproc-utils() {
    case "$1" in
    init)
        _cluster-init 
        # || echo "Cluster-Init Failed" & exit;
        _datalab-init
        ;;

    cleanup)
        _cleanup
        ;;

    cluster)
        case "$2" in
        start | up | init)
            _cluster-init
            ;;
        stop | down | delete | teardown)
            _cluster-teardown
            ;;
        ssh)
            _cluster-ssh
            ;;
        *)
            echo "Usage: $0 cluster {start|stop|ssh}"
            ;;
        esac
        ;;
        
    datalab)
        case "$2" in
        start | up | init)
            _datalab-init
            ;;
        stop | down | delete)
            echo "Press Ctrl+C in terminal running datalab. Quit datalab Chrome instance"
            ;;
        start-ssh-tunnel)
            _datalab-ssh-tunnel
            ;;
        start-browser)
            _datalab-chrome-socks
            ;;
        *)
            echo "Usage: $0 datalab {start|stop|start-ssh-tunnel|start-browser}"
            ;;
        esac
        ;;
    *)
        echo "Usage: $0 {init|cleanup|cluster|datalab}"
        ;;
    esac
}
