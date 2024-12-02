#!/bin/bash
LANG=en_US.UTF-8
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

down_url=https://gh.irenfeng.com/https://raw.githubusercontent.com/jakernel/btpanel-v7.7.0/main
# down_url=https://dl.sep.cc

echo "
+----------------------------------------------------------------------
| Bt-WebPanel-Happy FOR CentOS
+----------------------------------------------------------------------
| 本脚本用于宝塔面板7.7.0版本的一键开心优化，因为脚本造成的问题请自行负责！
+----------------------------------------------------------------------
"

if [ $(whoami) != "root" ];then
	echo "请使用root权限执行命令！"
	exit 1;
fi
if [ ! -d /www/server/panel ] || [ ! -f /etc/init.d/bt ];then
	echo "未安装宝塔面板"
	exit 1
fi


if [ ! -f /www/server/panel/data/userInfo.json ]; then
	echo "{\"uid\":1000,\"username\":\"admin\",\"serverid\":1}" > /www/server/panel/data/userInfo.json
fi
echo "已去除宝塔面板强制绑定账号."

#Layout_file="/www/server/panel/BTPanel/templates/default/layout.html";
#JS_file="/www/server/panel/BTPanel/static/bt.js";
#if [ `grep -c "<script src=\"/static/bt.js\"></script>" $Layout_file` -eq '0' ];then
#    sed -i '/{% block scripts %} {% endblock %}/a <script src="/static/bt.js"></script>' $Layout_file;
#fi;
#wget -q ${down_url}/install/bt.js -O $JS_file;
#echo "已去除各种计算题与延时等待."

sed -i "/htaccess = self.sitePath+'\/.htaccess'/, /public.ExecShell('chown -R www:www ' + htaccess)/d" /www/server/panel/class/panelSite.py
sed -i "/index = self.sitePath+'\/index.html'/, /public.ExecShell('chown -R www:www ' + index)/d" /www/server/panel/class/panelSite.py
sed -i "/doc404 = self.sitePath+'\/404.html'/, /public.ExecShell('chown -R www:www ' + doc404)/d" /www/server/panel/class/panelSite.py
echo "已去除创建网站自动创建的垃圾文件."

sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/class/panelSite.py
if [ -f /www/server/panel/vhost/nginx/0.default.conf ]; then
	sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/vhost/nginx/0.default.conf
fi
echo "已关闭未绑定域名提示页面."

#sed -i "s/return render_template('autherr.html')/return abort(404)/" /www/server/panel/BTPanel/__init__.py
#echo "已关闭安全入口登录提示页面."

sed -i "/p = threading.Thread(target=check_files_panel)/, /p.start()/d" /www/server/panel/task.py
sed -i "/p = threading.Thread(target=check_panel_msg)/, /p.start()/d" /www/server/panel/task.py
echo "已去除消息推送与文件校验."

if [ ! -f /www/server/panel/data/not_recommend.pl ]; then
	echo "True" > /www/server/panel/data/not_recommend.pl
fi
if [ ! -f /www/server/panel/data/not_workorder.pl ]; then
	echo "True" > /www/server/panel/data/not_workorder.pl
fi
echo "已关闭活动推荐与在线客服."
echo -e "正在关闭首页软件推荐与广告......"
sed -i "/return config/, /return /d" /www/server/panel/BTPanel/static/js/public.js
echo -e "正在关闭宝塔拉黑检测与提示......"
sed -i '/self._check_url/d' /www/server/panel/class/panelPlugin.py

#修改强制登录开始
sed -i "s|if (bind_user == 'True') {|if (bind_user == 'REMOVED') {|g" /www/server/panel/BTPanel/static/js/index.js
rm -rf /www/server/panel/data/bind.pl
#修改强制登录结束
echo -e "修改强制登陆中..."
sleep 2
echo -e "修改强制登陆结束."

sleep 2
echo -e "插件商城开心开始..."
#判断plugin.json文件是否存在,存在删除之后再下载,不存在直接下载
plugin_file="/www/server/panel/data/plugin.json"
if [ -f ${plugin_file} ];then
    chattr -i /www/server/panel/data/plugin.json
    rm /www/server/panel/data/plugin.json
    cd /www/server/panel/data
    wget ${down_url}/install/plugin.json
    chattr +i /www/server/panel/data/plugin.json
else
    cd /www/server/panel/data
    wget ${down_url}/install/plugin.json
    chattr +i /www/server/panel/data/plugin.json
fi
echo -e "插件商城开心结束."

sleep 3
echo -e "文件防修改开始..."
#判断repair.json文件是否存在,存在删除之后再下载,不存在直接下载
repair_file="/www/server/panel/data/repair.json"
if [ -f ${repair_file} ];then
    chattr -i /www/server/panel/data/repair.json
    rm /www/server/panel/data/repair.json
    cd /www/server/panel/data
    wget ${down_url}/install/repair.json
    chattr +i /www/server/panel/data/repair.json
else
    cd /www/server/panel/data
    wget ${down_url}/install/repair.json
    chattr +i /www/server/panel/data/repair.json
fi
echo -e "文件防修改结束."

echo -e "设置是否保存文件历史副本"
bt 25
echo -e "设置是否自动备份面板"
bt 18

/etc/init.d/bt restart
sleep 3
# bt default

echo -e "=================================================================="
echo -e "\033[32m宝塔面板优化脚本执行完毕\033[0m"
echo -e "=================================================================="
echo  "适用宝塔面板版本：7.7.0"
echo  "如需还原之前的样子，请在面板首页点击“修复”"
echo -e "=================================================================="
