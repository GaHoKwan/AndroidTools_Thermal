#!/bin/bash
echo -e "\e[40;32;1m"
clear
username=`whoami`
thisDir=`pwd`

#Environment Tools
addRulesFunc(){
	read mIdVendor mIdProduct
	echo "SUBSYSTEM==\"usb\", ATTR{idVendor}==\""$mIdVendor"\", ATTR{idProduct}==\""$mIdProduct"\", MODE=\"0600\", OWNER=\"$username\"" | sudo tee -a /etc/udev/rules.d/51-android.rules
	sudo /etc/init.d/udev restart
}

addRules(){
	clear
	lsusb
	echo -e "\nOK 上面列出了所有USB列表,大致内容如下:\n"
	echo -e "\033[40;37;7mBus 00x Device 00x: ID \033[40;34;7mxxxx\033[40;32;1m:\033[40;33;7mxxxx\033[40;30;0m \033[40;31;7mxxxxxxxxxxxxx\033[40;31;0m"
	echo -e "\e[40;32;1m"
	echo -e "如上，蓝色字符串为idVendor,黄色字符串为idProduct\n红色的是一些厂商信息(也可能没有)"
	echo -e "找第三个里面有没有你的手机厂商的名字,如:HUAWEI,ZTE 什么的"
	echo -e "当然没找到没关系,第三个什么都没有的就是了\n把idVendor和idProduct 打在下面,空格隔开,如:19d2 ffd0"
	echo -ne "\n输入:"
	addRulesFunc
	echo -e "添加成功"
}

installadbini(){
	echo -e "正在安装adb_usb.ini环境"
	cd $thisDir
	git clone https://github.com/GaHoKwan/adbusbini
	if [ "$?" -ne "0" ];then
		echo -e "下载环境配置文件错误，请检查错误！"
	else
		sudo rm -rf ~/.android
		sudo mv $thisDir/adbusbini ~/.android
	fi
}

installadb(){
	echo -e "\n配置adb环境变量..."
	sudo apt-get update
	sudo apt-get install android-tools-adb android-tools-fastboot
	installadbini
	curl https://raw.githubusercontent.com/GaHoKwan/Android-udev-rules/master/51-android.rules > $thisDir/51-android.rules
	cd $thisDir
	sudo cp 51-android.rules /etc/udev/rules.d/
	sudo chmod a+rx /etc/udev/rules.d/51-android.rules
	sudo /etc/init.d/udev restart
	echo "export PATH=$PATH:~/bin/" | sudo tee -a /etc/profile
	source /etc/profile
	sudo adb kill-server
	sudo adb devices
	echo "\n配置环境完成"
}

installia32(){
		if [ "$kind" == "" ]; then
		echo -e "\n开始安卓开发环境..."
		echo -e "请选择使用的系统版本:"
		echo -e "\t1. ubuntu 12.04 及以下(此项不安装编译环境）"
		echo -e "\t2. 其他(包括deepin等基于ubuntu的系统)"
		echo -en "选择:"
		read kind
		echo -e "\n开始配置32位运行环境..."
		fi
		if [ "$kind" == "1" ]; then
			sudo apt-get install ia32-libs
		elif [ "$kind" == "2" ]; then
#start
		cd /etc/apt/sources.list.d #进入apt源列表
		echo "deb http://old-releases.ubuntu.com/ubuntu/ raring main restricted universe multiverse" | sudo tee ia32-libs-raring.list
#添加ubuntu 13.04的源，因为13.10的后续版本废弃了ia32-libs
		sudo apt-get update #更新一下源
		if [ "$?" == "0" ]; then
			echo -e "下载完成"
			else
			echo -e "下载失败，正在重新尝试"
			sudo apt-get update
		fi
			sudo apt-get install ia32-libs #安装ia32-libs
		if [ "$?" == "0" ]; then
			echo -e "下载完成"
			else
			echo -e "下载失败，正在重新尝试"
			sudo apt-get install ia32-libs
		fi
		sudo rm ia32-libs-raring.list #恢复源
		sudo apt-get update #再次更新下源
#end
		else
			initSystemConfigure
		fi
}

initSystemConfigure(){
clear
echo -e "请输入你想安装的环境"
echo -e "\t1.ia32运行库"
echo -e "\t2.JavaSE(Oracle Java JDK)"
echo -e "\t3.aosp&cm&recovery编译环境"
echo -e "\t4.adb运行环境"
echo -e "\t5.AndroidSDK运行环境"
echo -e "\t6.hosts环境"
echo -e "\t7.安卓开发必备环境(上面1234）"
echo -ne "\n选择:"
read configurechoose
case $configurechoose in
	1)
		installia32
		read -p "按回车键继续..."
	;;
	2)
		installJavaSE
		read -p "按回车键继续..."
	;;
	3)
		DevEnvSetup
		read -p "按回车键继续..."
	;;
	4)
		installadb
		read -p "按回车键继续..."
	;;
	5)
		installsdk
	;;
	6)
		addhosts
		read anykey
	;;
	7)
		echo -e "\n开始安卓开发环境..."
		echo -e "请选择使用的系统版本:"
		echo -e "注意：由于apt源的完整性不足，选择1则不会安装编译环境"
		echo -e "\t1. ubuntu 12.04 及以下(此项不安装编译环境）"
		echo -e "\t2. 其他(包括deepin等基于ubuntu14.04的系统)"
		echo -e "\t3. Linux mint 17(此项不安装ia32因为Mint系统自带）"
		echo -en "选择:"
		read kind
		if [ "$kind" == "1" ]; then
			installrepo
			installia32
			installJavaSE
			installadb
		elif [ "$kind" == "2" ]; then
			installrepo
			installia32
			installJavaSE
			installadb
			DevEnvSetup
		elif [ "$kind" == "3" ]; then
			installrepo
			installJavaSE
			installadb
			DevEnvSetup
		else
			initSystemConfigure
		fi
		read -p "按回车键继续..."
	;;
esac
}

addhosts(){
echo -e "安装或更新hosts请按1，还原hosts请按2"
echo -ne "\n选择:"
read hostchoose
case $hostchoose in
	1)
		curl https://raw.githubusercontent.com/txthinking/google-hosts/master/hosts > $thisDir/hosts
		sudo mv  /etc/hosts /etc/hosts.bak
		sudo cp -f $thisDir/hosts /etc/hosts
		rm -rf $thisDir/hosts
		echo -e "hosts安装完成！"
	;;
	2)
		if [ `grep -rl youtube /etc/hosts` == "/etc/hosts" ]; then
			sudo mv /etc/hosts.bak /etc/hosts
		else
			echo -e "host已被还原过或者你没有安装过hosts"
		fi
	;;
esac
read -p "按回车键继续..."
}


installsdk(){
echo
echo "下载和配置 Android SDK!!"
echo "请确保 unzip 已经安装"
echo
sudo apt-get install unzip -y
if [ `getconf LONG_BIT` = "64" ];then
	echo
	echo "正在下载 Linux 64位 系统的Android SDK"
	wget http://dl.google.com/android/adt/adt-bundle-linux-x86_64-20140702.zip
	echo "下载完成!!"
	echo "展开文件"
	mkdir ~/adt-bundle
	mv adt-bundle-linux-x86_64-20140702.zip ~/adt-bundle/adt_x64.zip
	cd ~/adt-bundle
	unzip adt_x64.zip
	mv -f adt-bundle-linux-x86_64-20140702/* .
	echo "正在配置"
	echo -e '\n# Android tools\nexport PATH=${PATH}:~/adt-bundle/sdk/tools\nexport PATH=${PATH}:~/adt-bundle/sdk/platform-tools\nexport PATH=${PATH}:~/bin' >> ~/.bashrc
	echo -e '\nPATH="$HOME/adt-bundle/sdk/tools:$HOME/adt-bundle/sdk/platform-tools:$PATH"' >> ~/.profile
	echo "完成!!"
else
	echo
	echo "正在下载 Linux 32位 系统的Android SDK"
	wget http://dl.google.com/android/adt/adt-bundle-linux-x86-20140702.zip
	echo "下载完成!!"
	echo "展开文件"
	mkdir ~/adt-bundle
	mv adt-bundle-linux-x86-20140702.zip ~/adt-bundle/adt_x86.zip
	cd ~/adt-bundle
	unzip adt_x86.zip
	mv -f adt-bundle-linux-x86_64-20140702/* .
	echo "正在配置"
	echo -e '\n# Android tools\nexport PATH=${PATH}:~/adt-bundle/sdk/tools\nexport PATH=${PATH}:~/adt-bundle/sdk/platform-tools\nexport PATH=${PATH}:~/bin' >> ~/.bashrc
	echo -e '\nPATH="$HOME/adt-bundle/sdk/tools:$HOME/adt-bundle/sdk/platform-tools:$PATH"' >> ~/.profile
	echo "完成!!"
fi
rm -Rf ~/adt-bundle/adt-bundle-linux-x86_64-20140702
rm -Rf ~/adt-bundle/adt-bundle-linux-x86-20140702
rm -f ~/adt-bundle/adt_x64.zip
rm -f ~/adt-bundle/adt_x86.zip
read -p "按回车键继续..."
}

installkitchen(){
echo "安装安卓厨房"
		sudo apt-get install git -y
		cd ~/
		git clone https://github.com/kuairom/Android_Kitchen_cn
		if [ "$?" -ne "0" ];then
			read -p "安装失败，请检查报错信息，按回车键继续"
			main
		fi
		echo "安卓厨房已下载到主文件夹的Android_Kitchen_cn目录里！"
		read -p "按回车键继续..."
}

installJavaSE(){
	sudo apt-get update
	echo -e "\n开始安装oracle java developement kit..."
	sleep 1
	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get update && sudo apt-get install oracle-java6-installer
	if [ "$?" == "0" ]; then
		echo -e "下载完成"
		else
		echo -e "下载失败，正在重新尝试"
		sudo apt-get install  openjdk-7-jdk
	fi
	echo -e "\n安装openjdk7..."
	sleep 1
	sudo apt-get install  openjdk-7-jdk
	if [ "$?" == "0" ]; then
		echo -e "下载完成"
		else
		echo -e "下载失败，正在重新尝试"
		sudo apt-get install  openjdk-7-jdk
	fi
	read -p "按回车键继续..."
	echo 'alias jar-switch="sudo update-alternatives --config jar"' | sudo tee -a ~/.bashrc
	echo -e "你可以使用jar-switch命令来切换jar版本"
	echo 'alias java-switch="sudo update-alternatives --config java"' | sudo tee -a ~/.bashrc
	echo 'alias javac-switch="sudo update-alternatives --config javac"' | sudo tee -a ~/.bashrc
	echo 'alias javah-switch="sudo update-alternatives --config javah"' | sudo tee -a ~/.bashrc
	echo 'alias javap-switch="sudo update-alternatives --config javap"' | sudo tee -a ~/.bashrc
	source ~/.bashrc
	echo -e "你可以使用java(c/h/p)-switch命令来切换java(c/h/p)版本"
}

DevEnvSetup(){
	echo -e "\n开始安装ROM编译环境..."
	sudo apt-get install bison ccache libc6 build-essential curl flex g++-multilib g++ gcc-multilib git-core gnupg gperf x11proto-core-dev tofrodos libx11-dev:i386 libgl1-mesa-dev libreadline6-dev:i386 libgl1-mesa-glx:i386 lib32ncurses5-dev libncurses5-dev:i386 lib32readLine-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev python-markdown libxml2 libxml2-utils lzop squashfs-tools xsltproc pngcrush schedtool zip zlib1g-dev:i386 zlib1g-dev	
	if [ "$?" == "0" ]; then
		echo -e "下载完成"
		else
		echo -e "下载失败，正在重新尝试"
		DevEnvSetup
	fi
	sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so 
}

#Development tools
installrepo(){
	mkdir -p ~/bin
	curl https://raw.githubusercontent.com/FlymeOS/manifest/lollipop-5.0/repo > ~/bin/repo
 	chmod a+x ~/bin/repo
}

repoSource(){
	if [ ! -f ~/bin/repo ]; then
	installrepo
	fi
	clear
	echo -e "------ 同步源码 ------"
	echo -e "请输入存放源码的地址(可直接把文件夹拖进来):"
	echo -ne "\n输入:"
	read sDir
	cd ${sDir//\'//}
	repo init -u https://github.com/FlymeOS/manifest.git -b lollipop-5.0
	repo sync-j4
	if [ "$?" == "0" ]; then
		echo -e "同步完成"
		else
		echo -e "同步失败，正在重新尝试"
		repo sync -c --no-clone-bundle -j4
	fi
	cd $thisDir
	read -p "按回车键继续..."
}

fastrepoSource(){
	if [ ! -f ~/bin/repo ]; then
	installrepo
	fi
	clear
	echo -e "------ 跳过谷歌验证,快速同步源码 ------"
	echo -e "请输入存放源码的地址(可直接把文件夹拖进来):"
	echo -ne "\n输入:"
	read sDir
	cd ${sDir//\'//}
	repo init --repo-url git://github.com/FlymeOS/repo.git -u https://github.com/FlymeOS/manifest.git -b lollipop-5.0 --no-repo-verify
	repo sync -c --no-clone-bundle -j4
	if [ "$?" == "0" ]; then
		echo -e "同步完成"
		else
		echo -e "同步失败，正在重新尝试"
		repo sync -c --no-clone-bundle -j4
	fi
		read -p "按回车键继续..."
	cd $thisDir
}

logcat(){
echo -e "这是抓取log的工具，过程中按ctrl+c退出"
echo -e "是否打开logcat颜色显示功能，不选择默认将不使用颜色(y/n)"
read colorlogchoose
if [ "$colorlogchoose" == "y" ]; then
	curl https://raw.githubusercontent.com/GaHoKwan/colored-adb-logcat/master/colored-adb-logcat.py > $thisDir/colored-adb-logcat.py
	chmod a+x $thisDir/colored-adb-logcat.py
	logcat="python colored-adb-logcat.py"
else
	logcat="adb logcat -b main -b system -b radio"
fi
echo -e "正在切换模式..."
sleep 1
clear
echo -e "这是抓取log的工具，过程中按ctrl+c退出"
echo -e "\t\t1.把所有的log输出到$thisDir/log"
echo -e "\t\t2.把你想过滤的内容输出到终端并保存到文件"
echo -e "\t\t3.抓取VFY到文件"
echo -e "\t\t4.抓取E/AndroidRuntime到文件"
echo -e "\t\t5.抓取System.err到文件"
echo -e "\t\t6.抓取E/错误log到文件"
echo -ne "\n选择:"
read logcatmode
case $logcatmode in
	1)
		$logcat > $thisDir/log
	;;
	2)
		echo -e "\n输入你想过滤的内容"
		read ignoretext
		$logcat |grep $ignoretext|tee $thisDir/log
	;;
	3)
		$logcat |grep -C 5 'VFY'|tee $thisDir/log
	;;
	4)
		$logcat |grep 'E/AndroidRuntime'|tee $thisDir/log
	;;
	5)
		$logcat |grep 'System.err'|tee $thisDir/log
	;;
	6)
		$logcat |grep -C 5 'E/'|tee $thisDir/log
	;;
	*)
		main
	;;
esac
}

screencap(){
	adb shell /system/bin/screencap -p /data/local/tmp/screenshot.png
		cd $thisDir
		adb pull /data/local/tmp/screenshot.png
		if [ "$?" == "0" ]; then
		echo -e "截图文件已经输出到$thisDir"
		else
		echo -e "截图错误，请检查adb是否正常工作"
		fi
		read -p "按回车键继续..."
}

zipcenop(){
	echo -e "这是刷机包或者apk&jar伪加密工具"
	echo -e "请把需要加密的刷机包或者apk&jar拖进来"
	read cenopfile
	echo -ne "\n选择:"
	echo -e "输入1加密，输入2解密，输入任意字符退出"
	echo -ne "\n选择:"
	read cenopmode
case $cenopmode in
	1)
		java -jar $thisDir/ZipCenOp.jar e ${cenopfile//\'//}
		read -p "按回车键继续..."
	;;
	2)
		java -jar $thisDir/ZipCenOp.jar r ${cenopfile//\'//}
		read -p "按回车键继续..."
	;;
	*)
		main
	;;
esac
}

clean(){
	cd $thisDir
	echo -e "正在清理环境文件"
	rm -rf colored-adb-logcat.py 51-android.rules flyme.patch
	echo -e "输入c清理残留文件否则直接退出"
	echo -ne "\n输入c清理或者按回车退出:"
	read cleanchoose
	if [ "$cleanchoose" == "c" ]; then
		echo -e "正在清理残留文件"
		rm -rf log
		rm -rf screenshot.png
		read -p "按回车键继续..."
	fi
	echo -e "\e[0m"
}
 
main(){
clear 
echo -e "Android开发环境一键搭载脚本及开发工具"
echo "--作者： 嘉豪仔_Kwan (QQ:625336209 微博：www.weibo.com/kwangaho)"
echo -e "			输入命令号码 :\n"
echo -e "\t\t1. 使用root权限启动adb"
echo -e "\t\t2. 设置环境变量"
echo -e "\t\t3. 安装安卓厨房（Android-Kitchen)"
echo -e "\t\t4. 依然无法识别手机？没关系，选这个"
echo -e "\t\t5. 同步源码"
echo -e "\t\t6. 快速同步源码(跳过谷歌认证)"
echo -e "\t\t7. 伪加密工具"
echo -e "\t\t8. 抓取log工具"
echo -e "\t\t9. 手机截图"
echo -e "\t\t0. 离开脚本"
echo -ne "\n选择:"
read inp
case $inp in
	1)
		sudo adb kill-server
		sudo adb devices
		read -p "按回车键继续..."
		main
	;;
	2)
		initSystemConfigure
		main
	;;
	3)
		installkitchen
		main
	;;
	4)
		addRules
		main
	;;
	5)
		repoSource
		main
	;;
	6)
		fastrepoSource
		main
	;;
	7)
		zipcenop
		main
	;;
	8)
		logcat
		main
	;;
	9)
		screencap
		main
	;;
	0)
		clean
	;;
	*)
	main
	;;
esac
}

echo -e "说明：本脚本仅适用于Ubuntu及各大Ubuntu发行版使用，并且建议在14.04Lts版本下使用"
echo -ne "\n请输入你的root密码:" 
sudo echo -e "正在进入主界面..."
main
