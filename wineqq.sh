#!/bin/bash

cd /etc/apt/sources.list.d #进入apt源列表
echo "deb http://packages.linuxdeepin.com/deepin trusty main universe non-free" | sudo tee deepinwine-qqintl.list
echo "deb-src http://packages.linuxdeepin.com/deepin trusty main universe non-free" | sudo tee -a deepinwine-qqintl.list
sudo apt-get update #更新一下源
sudo apt-get install deepinwine-qqintl #安装ia32-libs
sudo rm deepinwine-qqintl.list #恢复源
sudo apt-get update #再次更新下源
