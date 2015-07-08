#!/bin/bash

#sudo add-apt-repository ppa:fcitx-team/nightly
#sudo apt-get update #更新一下源
sudo apt-get install fcitx fcitx-bin fcitx-config-common fcitx-config-gtk2 fcitx-data fcitx-frontend-gtk2 fcitx-frontend-gtk3 fcitx-frontend-qt4 fcitx-frontend-qt5 fcitx-libs fcitx-libs-gclient fcitx-libs-qt fcitx-libs-qt5 fcitx-module-dbus fcitx-module-kimpanel fcitx-module-x11 fcitx-modules fcitx-table fcitx-ui-classic libopencc1  #安装fcitx
sudo dpkg -i sogoupinyin_1.2.0.0042_amd64.deb #安装sogou_pinyin
echo "完成，按回车键继续"
read anykey
