#!/bin/bash

#展示路径
SHOW_FILE_PATH='/route/';
#域名链接
YOUR_DOMAIN='';
YOUR_DOMAIN_LINK='';
#监测目标
MONITORING_OBJECTIVES='';
#省略输出
OMITTED='true'; #省略输出没有内容的路由,true/false

#判断系统
CHECK_OS(){
	if [[ -f /etc/redhat-release ]];then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian";then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu";then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat";then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian";then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu";then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat";then
		release="centos"
	fi
}

#加载TRACEROUTE_BESTTRACE
TRACEROUTE_BESTTRACE(){
	INSTALL_BESTTRACE(){
		wget -P /root "http://ssr-file-1252089354.coshk.myqcloud.com/besttrace4linux.zip"
		if [ ! -e /usr/bin/unzip ];then
			CHECK_OS
			case "${release}" in
				centos)
					yum -y install unzip;;
				debian | ubuntu)
					apt-get -y install unzip;;
			esac
		fi
		unzip -q /root/besttrace4linux.zip -d /usr/bin
		rm -rf /root/besttrace4linux.zip
		chmod 777 /usr/bin/besttrace*
	}
	
	if [ ! -e /usr/bin/besttrace ];then
		INSTALL_BESTTRACE
	fi
}

#添加页首
ADD_THE_TOP(){
	echo "<!DOCTYPE html>
<html>
  
  <head>
    <title>TraceRoute - SERVER_ADDRESS</title>
    <meta name=\"viewport\" content=\"width=device-width\" charset=\"utf-8\" />
    <link rel=\"stylesheet\" href=\"//cdn.bootcss.com/mdui/0.4.0/css/mdui.min.css\">
    <script src=\"//cdn.bootcss.com/mdui/0.4.0/js/mdui.min.js\"></script>
  </head>
  
  <body>
  
  <div class=\"mdui-appbar\">
    <div class=\"mdui-toolbar mdui-color-indigo\">
      <p class=\"mdui-typo-title\">
        <i class=\"mdui-icon material-icons\">map</i>&nbsp;TraceRoute
	  </p>
      <div class=\"mdui-toolbar-spacer\"></div>
      <a onclick=\"javascript:location.reload();\" class=\"mdui-btn mdui-btn-icon\"><i class=\"mdui-icon material-icons\">refresh</i></a>

    </div>
  </div>
  
  <div>
    <div class=\"mdui-container-fluid\"><br/>
      <div class=\"mdui-row\">
        <div class=\"mdui-col-xs-12\">
          <div class=\"mdui-card\">
            <div class=\"mdui-card-primary\">
              <div class=\"mdui-card-primary-title\">TraceRoute : SERVER_ADDRESS</div>
              <div class=\"mdui-card-primary-subtitle\">最后更新于 : LAST_UPDATED_ON</div>
			</div>
          </div><br/>
          
          <div class=\"mdui-table-fluid\">
            <table class=\"mdui-table mdui-table-hoverable\">
              <thead>
                <tr>
                  <th>跳数</th>
                  <th>IP地址</th>
                  <th>延时</th>
                  <th>AS号</th>
                  <th>地区</th>
				</tr>
              </thead>
              <tbody>" > ${SHOW_FILE_PATH}${SERVER_ADDRESS}.html.tmp
}

#添加内容
ADD_CONTENT(){
	echo "Loading Data : ${SERVER_ADDRESS} ..."
	besttrace -q 1 ${SERVER_ADDRESS} > ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp
	#删除文件第一行,最后一行,和可能出现的IP地址
	sed -i '1d' ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp
	sed -i '$d' ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp
	sed -i "s/(\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\})//g" ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp
	#获取文件行数
	FILE_LINE=$(cat ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp | wc -l)
	#生成内容
	for (( i=1; i <= ${FILE_LINE}; i++ ))
	do
		#跳数
		HOPS=$(sed -n "${i}p" ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp | awk '{print $1}')
		#IP地址
		IP=$(sed -n "${i}p" ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp | awk '{print $2}')
		#延时
		DELAY=$(sed -n "${i}p" ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp | awk '{print $3,$4}')
		#AS号
		AS_NUMBER=$(sed -n "${i}p" ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp | awk '{print $5}')
		#地址信息
		AREA=$(sed -n "${i}p" ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp | awk '{print $6,$7,$8,$9,$10}')
		
		if [[ ${OMITTED} = "true" ]];then
			if [[ ${AS_NUMBER} != "" ]];then
				echo "			  <tr>
					<td>${HOPS}</td>
					<td>${IP}</td>
					<td>${DELAY}</td>
					<td>${AS_NUMBER}</td>
					<td>${AREA}</td>
				  </tr>"
			fi
		else
			echo "			  <tr>
					<td>${HOPS}</td>
					<td>${IP}</td>
					<td>${DELAY}</td>
					<td>${AS_NUMBER}</td>
					<td>${AREA}</td>
				  </tr>"
		fi
		
	done >> ${SHOW_FILE_PATH}${SERVER_ADDRESS}.html.tmp
}

#编辑内容
EDIT_CONTENT(){
	NOW_TIME=$(date "+%Y-%m-%d %H:%M:%S")
	sed -i "s/LAST_UPDATED_ON/${NOW_TIME}/g" ${SHOW_FILE_PATH}${SERVER_ADDRESS}.html.tmp
	sed -i "s/SERVER_ADDRESS/${SERVER_ADDRESS}/g" ${SHOW_FILE_PATH}${SERVER_ADDRESS}.html.tmp
}

#添加页尾
ADD_THE_FOOTER(){
	echo "			  </tbody>
            </table>
		  </div>
		  
        </div>
      </div>
      <p style=\"text-align:center\">© 2017~2018 ${YOUR_DOMAIN} All Rights Reserved.</p>
	</div>
  </div>
  
  </body>
</html>" >> ${SHOW_FILE_PATH}${SERVER_ADDRESS}.html.tmp
	
	EDIT_CONTENT
	rm -rf ${SHOW_FILE_PATH}${SERVER_ADDRESS}.tmp
	mv ${SHOW_FILE_PATH}${SERVER_ADDRESS}.html.tmp ${SHOW_FILE_PATH}${SERVER_ADDRESS}.html
}

RUN_TRACEROUTE(){
	for SERVER_ADDRESS in ${MONITORING_OBJECTIVES}
	do
		ADD_THE_TOP
		ADD_CONTENT
		ADD_THE_FOOTER
	done
	
	echo "Done."
}

clear
TRACEROUTE_BESTTRACE
RUN_TRACEROUTE
