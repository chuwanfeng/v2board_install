#!/bin/sh
#
#Date:2024.1.19
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
# 从接收信息后开始统计脚本执行时间
START_TIME=`date +%s`

echo "\033[36m#######################################################################\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#                  正在配置Firewall策略 放行TCP80、443 请稍等~            #\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#######################################################################\033[0m"
ufw allow 80/tcp
ufw allow 443/tcp
ufw status
#放行TCP80、443端口


echo "\033[36m#######################################################################\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#                 安装nginx/mariadb/redis/certbot                      #\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#######################################################################\033[0m"
sudo apt update
apt -y install curl apt-transport-https ca-certificates lsb-release
apt -y install nginx python3-certbot-nginx mariadb-server redis-server

echo "\033[36m#######################################################################\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#                 安装安装php8.2                    #\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#######################################################################\033[0m"
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt -y install php8.2 php8.2-cli \
php8.2-fpm php8.2-gd php8.2-mysql php8.2-mbstring \
php8.2-curl php8.2-xml php8.2-xmlrpc php8.2-zip \
php8.2-intl php8.2-bz2 php8.2-bcmath php8.2-redis

echo "\033[36m#######################################################################\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#                 安装composer                                         #\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#######################################################################\033[0m"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

echo "\033[36m#######################################################################\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#                   正在配置mariadb数据库 请稍等~                        #\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#######################################################################\033[0m"
mysql_secure_installation
while :; do echo
    read -p "请输入Mysql数据库root密码: " Database_Password
    [ -n "$Database_Password" ] && break
done
mysqladmin -u root password "$Database_Password"
echo "---mysqladmin -u root password "$Database_Password""
#修改数据库密码
mysql -uroot -p$Database_Password -e "CREATE DATABASE v2board CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
                                      GRANT ALL PRIVILEGES ON v2board.* TO v2board@localhost IDENTIFIED BY 'password';
                                      FLUSH PRIVILEGES;
                                      quit"
echo $?="正在创建v2board数据库"


echo "\033[36m#######################################################################\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#                    正在部署V2board 请稍等~                          #\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#######################################################################\033[0m"
cd /var/www
git clone https://github.com/chuwanfeng/v2board.git
cd v2board/

echo "\033[36m安装依赖： \033[0m"
composer install

echo "\033[36m安装V2board： \033[0m"
php artisan v2board:install

echo "\033[36m修改权限和所有者： \033[0m"
cd /var/www
chmod -R 755 v2board/
chown -R www-data:www-data v2board/

# 添加定时任务
echo "\033[36m添加计划任务： \033[0m"
echo "* * * * * php /var/www/v2board/artisan schedule:run >> /dev/null 2>&1" >> /etc/crontab.v2
crontab -u www-data /etc/crontab.v2

# 新建队列服务
echo "\033[36m新建队列服务： \033[0m"
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

echo "\033[36m#######################################################################\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#                    正在配置Nginx 请稍等~                               #\033[0m"
echo "\033[36m#                                                                     #\033[0m"
echo "\033[36m#######################################################################\033[0m"
cat > /etc/nginx/sites-available/v2board <<"eof"
server {
    listen      80 http2;
    server_name www.heima001.com;
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
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
eof
echo "启用站点"
ln -s /etc/nginx/sites-available/v2board /etc/nginx/sites-enabled/v2board
echo "签发ssl证书"
certbot --nginx

#获取主机内网ip
ip="$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')"
#获取主机外网ip
ips="$(curl ip.sb)"

# 加入开机启动
systemctl restart php8.2-fpm mysqld redis nginx
systemctl enable php8.2-fpm mariadb nginx redis-server
systemctl is-enabled php8.2-fpm mariadb nginx redis-server horizon
echo $?="服务启动完成"
# 清除缓存垃圾
rm -rf /usr/local/src/v2board_install
#rm -rf /usr/local/src/lnmp_rpm
#rm -rf /usr/share/nginx/html/v2board/public/LuFly

# V2Board安装完成时间统计
END_TIME=`date +%s`
EXECUTING_TIME=`expr $END_TIME - $START_TIME`
echo "\033[36m本次安装使用了$EXECUTING_TIME S!\033[0m"

echo "\033[32m--------------------------- 安装已完成 ---------------------------\033[0m"
echo "\033[32m##################################################################\033[0m"
echo "\033[32m#                            V2board                             #\033[0m"
echo "\033[32m##################################################################\033[0m"
echo "\033[32m 数据库用户名   :root\033[0m"
echo "\033[32m 数据库密码     :"$Database_Password
echo "\033[32m 网站目录       :/var/www/v2board \033[0m"
echo "\033[32m Nginx配置文件  :/etc/nginx/sites-available/v2board \033[0m"
echo "\033[32m PHP配置目录    :/etc/php/8.2/fpm/php.ini \033[0m"
echo "\033[32m 内网访问       :http://"$ip
echo "\033[32m 外网访问       :http://"$ips
echo "\033[32m 安装日志文件   :/var/log/"$install_date
echo "\033[32m------------------------------------------------------------------\033[0m"

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
