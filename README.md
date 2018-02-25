# 简介
通过ping简单的判定监控目标至中国网络连通性，[演示站点](http://116.196.111.178/)

# 环境
- 位于中国的云服务器
- Nginx / Caddy
- CentO / Debian / Ubuntu 系统

# 应用
以Nginx为例，先新建一个站点
```
lnmp vhost add
```
假设站点是 `csb.domain.com` ，目录 `/home/wwwroot/csb.domain.com` 则
```
mkdir /home/wwwroot/csb.domain.com/route
```
建立一个目录放置脚本，假设准备放置在 `/root/csb` ，则
```
mkdir /root/csb
cd /root/csb
git clone https://github.com/qinghuas/Check-Server-Blocked.git
mv Check-Server-Blocked/* ./
rm -rf Check-Server-Blocked
```
然后编辑 `check.sh`  

- 绝对路径：假设站点是 `csb.domain.com` ，目录是 `/home/wwwroot/csb.domain.com` ，则绝对路径是 `/home/wwwroot/csb.domain.com` + `/index.html`
```
#绝对路径
SHOW_FILE_PATH='/home/wwwroot/csb.domain.com/index.html';
```
- 域名链接：假设站点是 `csb.domain.com` ，则 `YOUR_DOMAIN` 可以设置为 `csb.domain.com` ，`YOUR_DOMAIN_LINK` 可以设置为 `http://csb.domain.com` 或 `https://csb.domain.com`
```
#域名链接
YOUR_DOMAIN='csb.domain.com';
YOUR_DOMAIN_LINK='https://csb.domain.com';
```
- 网站标题：主页的网站标题，可以自定义
```
#网站标题
WWW_TITLE='Check Server Blocked';
```
- ping频率：数值越大越准确，但是耗时越长。如若耗时超过定时任务的频率，会导致网页内容重复。建议 `3-5`
```
#ping频率
PING_FREQUENCY='3';
```
- 监测目标：多个目标用空格分隔
```
#监测目标
MONITORING_OBJECTIVES='';
```
- 颜色设定：默认是分了三挡，颜色在0-100ms，一档，绿色；颜色在100-200ms，二档，橙色；大于200ms，三挡，红色
```
#颜色设定
COLOR_ONE='green'; #一档颜色,默认:green
COLOR_TWO='#E67E22'; #二档颜色,默认:#E67E22
COLOR_THREE='red'; #三档颜色,默认:red
#颜色阈值设定
PING_COLOR_ONE='100'; #一档颜色设置阈值,默认:100
PING_COLOR_TWO='200'; #二档颜色设置阈值,默认:200
```
- 统计默认值：这个就不要动了
```
#统计默认值
ALL_NUMBER='0';
LOCK_NUMBER='0';
UNLOCK_NUMBER='0';
```
然后编辑 `traceroute.sh`  
- 展示路径：假设站点是 `csb.domain.com` ，目录是 `/home/wwwroot/csb.domain.com` ，则展示路径是 `/home/wwwroot/csb.domain.com` + `/route/`
```
#展示路径
SHOW_FILE_PATH='/route/';
```
- 域名链接、监测目标：见上

- 省略输出：是否省略输出没有内容的路由，设为true则省略
```
#省略输出
OMITTED='true'; #省略输出没有内容的路由,true/false
```
然后设置定时任务： `crontab -e`

以下设置是十分钟执行一次，如若想5分钟执行一次，将10更改为5即可
```
*/10 * * * * /bin/bash /root/csb/check.sh
```
以下设置是每小时执行一次
```
0 * * * * /bin/bash /root/csb/traceroute.sh
```
然后`ESC`，`:wq`，保存
# 建议
- ping频率：数值越大越准确，但是耗时越长。如若耗时超过定时任务的频率，会导致网页内容重复，建议根据检测目标数量适当调整。
- 中国服务器建站：一般http访问会被服务商屏蔽，推荐启用https，可以绕过。
- 时间仓促，脚本还存在一些不完善的地方，后续会慢慢优化。

# 更多

主题：[MDUI](https://mdui.org)
