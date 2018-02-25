#!/bin/bash

#绝对路径
SHOW_FILE_PATH='/index.html';
#域名链接
YOUR_DOMAIN='';
YOUR_DOMAIN_LINK='';
#网站标题
WWW_TITLE='Check Server Blocked';
#ping频率
PING_FREQUENCY='3';
#监测目标
MONITORING_OBJECTIVES='';
#颜色设定
COLOR_ONE='green'; #一档颜色,默认:green
COLOR_TWO='#E67E22'; #二档颜色,默认:#E67E22
COLOR_THREE='red'; #三档颜色,默认:red
#颜色阈值设定
PING_COLOR_ONE='100'; #一档颜色设置阈值,默认:100
PING_COLOR_TWO='200'; #二档颜色设置阈值,默认:200
#统计默认值
ALL_NUMBER='0';
LOCK_NUMBER='0';
UNLOCK_NUMBER='0';

#添加页首
ADD_THE_TOP(){
	echo "<!DOCTYPE html>
<html>

<head>
  <title>${WWW_TITLE}</title>
  <meta name=\"viewport\" content=\"width=device-width\" charset=\"utf-8\" />
  <link rel=\"stylesheet\" href=\"//cdn.bootcss.com/mdui/0.4.0/css/mdui.min.css\">
  <script src=\"//cdn.bootcss.com/mdui/0.4.0/js/mdui.min.js\"></script>
  <style>
	a:link {color:black;}
	a:visited {color:black;}
	a:hover {color:black;}
	a:active {color:black;}
  </style>
</head>

<body>

</body>
<div class=\"mdui-appbar\">
  <div class=\"mdui-toolbar mdui-color-indigo\">
    <p class=\"mdui-typo-title\"><i class=\"mdui-icon material-icons\">lock_open</i>&nbsp;${WWW_TITLE}</p>
    <div class=\"mdui-toolbar-spacer\"></div>
    <a href=\"/\" class=\"mdui-btn mdui-btn-icon\"><font color=\"white\"><i class=\"mdui-icon material-icons\">refresh</i></font></a>
  </div>
</div>
  
<div>
  <div class=\"mdui-container-fluid\">
    <br/>
      <div class=\"mdui-row\">
        <div class=\"mdui-col-xs-12\">
		
          <div class=\"mdui-card\">
            <div class=\"mdui-card-primary\">
              <div class=\"mdui-card-primary-title\">${WWW_TITLE}</div>
              <div class=\"mdui-card-primary-subtitle\">最后更新于 : LAST_UPDATED_ON</div>
            </div>
            <div class=\"mdui-card-content\">
              连通状况 : STATISTICAL_DATA
            </div>
		  </div>
		  
		  <br/>
		  
		  <table class=\"mdui-table mdui-table-hoverable\">
			<thead>
			  <tr>
				<th>ID</th>
				<th>服务器</th>
				<th>状态</th>
				<th>延时</th>
			  </tr>
			</thead>
			<tbody>" > ${SHOW_FILE_PATH}.loading
}

#延时与颜色
DELAY_AND_COLOR(){
	#如果${PING_DELAY}大于0且小于等于${PING_COLOR_ONE}
	if [[ "${PING_DELAY}" -gt "0" ]] && [[ "${PING_DELAY}" -le "${PING_COLOR_ONE}" ]];then
		PING_DELAY_COLOR=${COLOR_ONE}
	fi
	#如果${PING_DELAY}大于${PING_COLOR_ONE}且小于等于${PING_COLOR_TWO}
	if [[ "${PING_DELAY}" -gt "${PING_COLOR_ONE}" ]] && [[ "${PING_DELAY}" -le "${PING_COLOR_TWO}" ]];then
		PING_DELAY_COLOR=${COLOR_TWO}
	fi
	#如果${PING_DELAY}大于${PING_COLOR_TWO}
	if [[ "${PING_DELAY}" -gt "${PING_COLOR_TWO}" ]];then
		PING_DELAY_COLOR=${COLOR_THREE}
	fi
}

#添加内容
ADD_CONTENT(){
	for SERVER in ${MONITORING_OBJECTIVES}
	do
		echo "Loading Data : ${SERVER} ..."
		ALL_NUMBER=$(expr ${ALL_NUMBER} + 1)
		PING_TEST=$(ping ${SERVER} -c ${PING_FREQUENCY} > ${SHOW_FILE_PATH}.tmp)
		PACKET_LOSS_RESULTS=$(cat ${SHOW_FILE_PATH}.tmp | grep transmitted | awk '{print $6}')
		PING_DELAY=$(cat ${SHOW_FILE_PATH}.tmp | grep rtt | cut -d "/" -f 5 | awk -F. '{print $1}')
		DELAY_AND_COLOR
		if [ ${PACKET_LOSS_RESULTS} = "100%" ];then
			LOCK_NUMBER=$(expr ${LOCK_NUMBER} + 1)
			STATUS='异常'
			PING_DELAY='/'
			PING_DELAY_COLOR='black'
			echo "			  <tr>
				<td>${ALL_NUMBER}</td>
				<td><a href=\"${YOUR_DOMAIN_LINK}/route/${SERVER}.html\" target=\"_blank\" style=\"text-decoration:none;\">${SERVER}</a></td>
				<td><font color=\"red\"><b>${STATUS}</b></font></td>
				<td><font color=\"${PING_DELAY_COLOR}\"><b>${PING_DELAY}</b></font></td>
			  </tr>" >> ${SHOW_FILE_PATH}.loading
		else
			UNLOCK_NUMBER=$(expr ${UNLOCK_NUMBER} + 1)
			STATUS='正常'
			echo "			  <tr>
				<td>${ALL_NUMBER}</td>
				<td><a href=\"${YOUR_DOMAIN_LINK}/route/${SERVER}.html\" target=\"_blank\" style=\"text-decoration:none;\">${SERVER}</a></td>
				<td><font color=\"green\"><b>${STATUS}</b></font></td>
				<td><font color=\"${PING_DELAY_COLOR}\"><b>${PING_DELAY}</b></font></td>
			  </tr>" >> ${SHOW_FILE_PATH}.loading
		fi
	done
	
	echo "Done."
}

#添加页尾
ADD_THE_FOOTER(){
	echo "			</tbody>
		  </table>
		</div>
	  </div>
	<br/>
	<p style=\"text-align:center\">© 2017~2018 ${YOUR_DOMAIN} All Rights Reserved.</p>
  </div>
</div>
</html>" >> ${SHOW_FILE_PATH}.loading
}

EDIT_CONTENT(){
	NOW_TIME=$(date "+%Y-%m-%d %H:%M:%S")
	sed -i "s/LAST_UPDATED_ON/${NOW_TIME}/g" ${SHOW_FILE_PATH}.loading
	sed -i "s/STATISTICAL_DATA/总 ${ALL_NUMBER}，正常 ${UNLOCK_NUMBER}，异常 ${LOCK_NUMBER}/g" ${SHOW_FILE_PATH}.loading
	mv ${SHOW_FILE_PATH}.loading ${SHOW_FILE_PATH}
}

clear
ADD_THE_TOP
ADD_CONTENT
ADD_THE_FOOTER
EDIT_CONTENT