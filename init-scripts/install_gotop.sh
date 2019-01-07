#!/bin/bash

git clone --depth 1 https://github.com/cjbassi/gotop.git /tmp/gotop
/tmp/gotop/scripts/download.sh
echo $PATH
sudo mv gotop /usr/local/bin/

