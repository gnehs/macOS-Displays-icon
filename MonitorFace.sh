#!/bin/sh
version=0.4.1
localtext_zh_CN() {
cat <<EOF


                       -- MonitorFace --
                     v$version © lihaoyun6 2020
                自动识别并安装符合显示器真实外观的图标
              本项目基于本人维护的显示器个性化图标数据库
 欢迎向 👉https://github.com/lihaoyun6/macOS-Displays-icon 提交图标


EOF
	welcome="欢迎向 👉https://github.com/lihaoyun6/macOS-Displays-icon 提交图标"
	checkdisplay="正在检测显示器数据..."
	finded="共找到 "
	displays=" 台显示器"
	checkdatabase="正在搜索数据库..."
	text1="第 "
	text2=" 台显示器: "
	text3=" 的图标已找到"
	downloading="正在下载图标数据..."
	installing="正在安装图标..."
	remounting="正在解除写保护..."
	ntext3=" 的图标未找到"
	displayname="显示器名称: "
	displayvid=", 显示器VID: "
	displaypid=", 显示器PID: "
	alldone="所有显示器图标已安装完成. 重启或重新拔插显示器即可看到效果."
	hr="=================================================================="
}
localtext_en_US() {
cat <<EOF


                       -- MonitorFace --
                     v$version © lihaoyun6 2018
            Automatically identify the monitor model
      and install icon file that shows how the monitor looks
Share your icon 👉https://github.com/lihaoyun6/macOS-Displays-icon


EOF
	welcome="Share your icon 👉https://github.com/lihaoyun6/macOS-Displays-icon"
	checkdisplay="Checking monitor(s) info..."
	finded=""
	displays=" monitor(s) found"
	checkdatabase="Searching from database..."
	text1="The icon of monitor "
	text2=" ("
	text3=") has been found"
	downloading="Downloading icon file..."
	installing="Installing icon file..."
	remounting="Remounting filesystem writeable..."
	ntext3=") cannot be found"
	displayname="Monitor: "
	displayvid=", VendorID: "
	displaypid=", ProductID: "
	alldone="All icon files have been installed. Please replug your monitor."
	hr="=================================================================="
}
icon() {
	echo $checkdisplay
	edids=$(ioreg -lw0|grep IODisplayEDID|grep -o "<.*>"|sed "s/[<>]//g")
	vids=$(printf "%x\n" $(ioreg -l | grep "DisplayVendorID"|awk '{print $NF}'))
	pids=$(printf "%x\n" $(ioreg -l | grep "DisplayProductID"|awk '{print $NF}'))
	num=$(echo $vids|awk '{print NF}')
	echo $finded$num$displays
	echo $checkdatabase
	echo $hr
	for i in $(seq 1 $num);do
		vid=$(printf "$vids\n"|sed -n "${i}p")
		pid=$(printf "$pids\n"|sed -n "${i}p")
		name=$(printf "$edids\n"|sed -n "${i}p"|grep -Eo "fc00.*?0a"|sed "s/^fc00//g"|xxd -r -p)
		valid=$(curl -s $url/${vid}/${vid}.pid|grep -o "${pid}:")
		if [ x"$valid" = x"${pid}:" ];then
			echo $text1$i$text2$name$text3
			echo $displayname$name$displayvid$vid$displaypid$pid
			echo $downloading
			curl -s ${url}/${vid}/${pid}.icns > /tmp/DisplayProductID-${pid}.icns
			echo $installing
			if [ $(sw_vers -productVersion|awk -F '.' '{print $2}') -ge 15 ];then
				echo $remounting
				mount -o rw /
			fi
			mkdir -p $1/DisplayVendorID-${vid}
			mv -f /tmp/DisplayProductID-${pid}.icns $1/DisplayVendorID-${vid}/
			echo $hr
		else
			echo $text1$i$text2$name$ntext3
			echo $displayname$name$displayvid$vid$displaypid$pid
			echo $welcome
			echo $hr
		fi
	done
	echo $alldone
}

add=$(/usr/bin/curl -s cip.cc|grep -o -m1 "中国")
if [ x"$add" = x"中国" ];then
	url="https://gitee.com/lihaoyun/macOS-Displays-icon/raw/master"
else
	url="https://raw.githubusercontent.com/lihaoyun6/macOS-Displays-icon/master"
fi
lang=$(osascript -e 'user locale of (get system info)')
#lang=qqq
if [ x"$lang" = x"zh_CN" ];then
	localtext_zh_CN
else
	localtext_en_US
fi

sys=$(sw_vers -buildVersion|grep -Eo "^\d+")
if [ "$sys" -ge 15 ];then
	icon "/Library/Displays/Contents/Resources/Overrides"
else
	icon "/System/Library/Displays/Overrides"
fi
