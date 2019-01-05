#!/usr/local/bin/bash

# Removve Aliases
unalias dataproc-cluster-init
unalias dataproc-ssh-tunnel
unalias dataproc-chrome-socks
unalias dataproc-ssh

# Deprovision  Cluster
gcloud dataproc clusters delete "${CLUSTER}"
