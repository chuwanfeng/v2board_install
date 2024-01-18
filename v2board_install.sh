#!/bin/sh
#
#Date:2023.10.07
#Author:魅lan.肉肉
#Mail:chuwanfeng@hotmail.com

red='\033[0;31m'
green='\033[36m'
yellow='\033[0;33m'
plain='\033[0m'

process()
{
install_date="V2board_install_$(date +%Y-%m-%d_%H:%M:%S).log"
printf "
\033[36m#######################################################################
#                     欢迎使用V2board一键部署脚本                     #
#                       脚本适配环境Debian11+               #
#                更多信息请访问 https://github.com/chuwanfeng/v2board_install              #
#######################################################################\033[0m
"

#while :; do echo
#    read -p "请输入Mysql数据库root密码: " Database_Password
#    [ -n "$Database_Password" ] && break
#done

# 从接收信息后开始统计脚本执行时间
START_TIME=`date +%s`

echo -e "\033[36m#######################################################################\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#                  正在配置Firewall策略 放行TCP80、443 请稍等~            #\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#######################################################################\033[0m"
apt install ufw
ufw allow 80/tcp
ufw allow 443/tcp
ufw status
ufw enable
systemctl start ufw
#放行TCP80、443端口


echo -e "\033[36m#######################################################################\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#                 安装nginx/mariadb/redis/certbot                      #\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#######################################################################\033[0m"
apt -y install nginx python3-certbot-nginx mariadb-server redis-server

echo -e "\033[36m#######################################################################\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#                 安装安装php7.4                    #\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#######################################################################\033[0m"
apt -y install curl apt-transport-https ca-certificates lsb-release
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt -y install php7.4-common php7.4-cli \
php7.4-fpm php7.4-gd php7.4-mysql php7.4-mbstring \
php7.4-curl php7.4-xml php7.4-xmlrpc php7.4-zip \
php7.4-intl php7.4-bz2 php7.4-bcmath php7.4-redis

echo -e "\033[36m#######################################################################\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#                 安装composer                                         #\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#######################################################################\033[0m"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

echo -e "\033[36m#######################################################################\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#                   正在配置mariadb数据库 请稍等~                        #\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#######################################################################\033[0m"
mysql_secure_installation
mysqladmin -u root password "$Database_Password"
echo "---mysqladmin -u root password "$Database_Password""
#修改数据库密码
mysql -uroot -p$Database_Password -e "CREATE DATABASE v2board CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
                                      GRANT ALL PRIVILEGES ON v2board.* TO v2board@localhost IDENTIFIED BY 'password';
                                      FLUSH PRIVILEGES;
                                      quit"
echo $?="正在创建v2board数据库"


echo -e "\033[36m#######################################################################\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#                    正在部署V2board 请稍等~                          #\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#######################################################################\033[0m"
cd /var/www
git clone https://github.com/chuwanfeng/v2board.git
cd v2board/

echo -e "\033[36m安装依赖： \033[0m"
composer install

echo -e "\033[36m安装V2board： \033[0m"
php artisan v2board:install

echo -e "\033[36m修改权限和所有者： \033[0m"
chmod -R 755 v2board/
chown -R www-data:www-data v2board/

# 添加定时任务
echo -e "\033[36m添加计划任务： \033[0m"
crontab -u www-data -e <<"eof"
* * * * * php /var/www/v2board/artisan schedule:run >> /dev/null 2>&1
eof

# 新建队列服务
echo -e "\033[36m新建队列服务： \033[0m"
cat >  /etc/systemd/system/horizon.service <<"eof"
[Unit]
Description=Laravel Horizon Queue Manager
After=network.target

[Service]
user=www-data
ExecStart=/usr/bin/php /var/www/v2board/artisan horizon
Restart=always

[Install]
WantedBy=multi-user.target
eof

# 启动并设置开机启动
systemctl enable --now horizon.service


echo -e "\033[36m#######################################################################\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#                    正在配置PHP.ini 请稍等~                          #\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#######################################################################\033[0m"
sed -i "s/post_max_size = 8M/post_max_size = 32M/" /etc/php.ini
sed -i "s/max_execution_time = 30/max_execution_time = 600/" /etc/php.ini
sed -i "s/max_input_time = 60/max_input_time = 600/" /etc/php.ini
sed -i "s#;date.timezone =#date.timezone = Asia/Shanghai#" /etc/php.ini
# 配置php-sg11
mkdir -p /sg
wget -P /sg/  https://cdn.jsdelivr.net/gh/gz1903/sg11/Linux%2064-bit/ixed.7.3.lin
sed -i '$a\extension=/sg/ixed.7.3.lin' /etc/php.ini
#修改PHP配置文件
echo $?="PHP.inin配置完成完成"

echo -e "\033[36m#######################################################################\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#                    正在配置Nginx 请稍等~                               #\033[0m"
echo -e "\033[36m#                                                                     #\033[0m"
echo -e "\033[36m#######################################################################\033[0m"
cat > /etc/nginx/sites-available/v2board <<"eof"
server {
    listen      80;
    server_name chuwanfeng.com;
    root        /var/www/v2board/public;
    index       index.php;
    client_max_body_size 0;

    location /downloads {
    }

    location / {
        try_files $uri $uri/ /index.php$is_args$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }
}
eof
echo -e "启用站点"
ln -s /etc/nginx/sites-available/v2board /etc/nginx/sites-enabled/v2board
echo -e "签发ssl证书"
certbot --nginx

#获取主机内网ip
ip="$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')"
#获取主机外网ip
ips="$(curl ip.sb)"

systemctl restart php-fpm mysqld redis && nginx
echo $?="服务启动完成"
# 清除缓存垃圾
rm -rf /usr/local/src/v2board_install
rm -rf /usr/local/src/lnmp_rpm
rm -rf /usr/share/nginx/html/v2board/public/LuFly

# V2Board安装完成时间统计
END_TIME=`date +%s`
EXECUTING_TIME=`expr $END_TIME - $START_TIME`
echo -e "\033[36m本次安装使用了$EXECUTING_TIME S!\033[0m"

echo -e "\033[32m--------------------------- 安装已完成 ---------------------------\033[0m"
echo -e "\033[32m##################################################################\033[0m"
echo -e "\033[32m#                            V2board                             #\033[0m"
echo -e "\033[32m##################################################################\033[0m"
echo -e "\033[32m 数据库用户名   :root\033[0m"
echo -e "\033[32m 数据库密码     :"$Database_Password
echo -e "\033[32m 网站目录       :/var/www/v2board \033[0m"
echo -e "\033[32m Nginx配置文件  :/etc/nginx/conf.d/v2board.conf \033[0m"
echo -e "\033[32m PHP配置目录    :/etc/php.ini \033[0m"
echo -e "\033[32m 内网访问       :http://"$ip
echo -e "\033[32m 外网访问       :http://"$ips
echo -e "\033[32m 安装日志文件   :/var/log/"$install_date
echo -e "\033[32m------------------------------------------------------------------\033[0m"

}
LOGFILE=/var/log/"V2board_install_$(date +%Y-%m-%d_%H:%M:%S).log"
touch $LOGFILE
tail -f $LOGFILE &
pid=$!
exec 3>&1
exec 4>&2
exec &>$LOGFILE
process
ret=$?
exec 1>&3 3>&-
exec 2>&4 4>&-
