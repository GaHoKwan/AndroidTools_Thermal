#!/bin/bash
Configurechoose=$(whiptail --title "请输入你想安装的环境" --menu "选择" 15 60 4 \
"1" "ia32运行库" \
"2" "JavaSE(Oracle Java JDK" \
"3" "aosp&cm&recovery编译环境" \
"4" "adb运行环境"  3>&1 1>&2 2>&3)
case $Configurechoose in
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
		echo -e "\n由于翻译工作暂未完成，该功能将于后续版本开放，按回车键继续"
		read anykey
	;;
	7)
		echo -e "\n由于hosts的不稳定性，所以于flyme专版去除该功能，按回车键继续"
		read anykey
	;;
esac
}
