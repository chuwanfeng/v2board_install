# V2board一键部署

**脚本适用于操作系统：Debian11+部署，内存1G内存，磁盘容量大于5G,部署环境最好使用单独的服务器，避免环境冲突。**

#### 环境介绍(仅介绍脚本自动安装的环境，跑脚本前不需要安装任何环境)：

```shell
Nginx   1.22.1
MariaDB 10.11.4
PHP     PHP 8.2
redis   7.0.11
```
> 测试1H1G机器部署，170s左右即可。请使用Debian11+系列纯净主机部署。


#### 软件版本：

```
V2board 1.7.4
```

#### 一键部署脚本：

```shell
apt-get update && apt-get install -y git wget && git clone https://github.com/chuwanfeng/v2board_install.git /usr/local/src/v2board_install && cd /usr/local/src/v2board_install && chmod +x v2board_install.sh && ./v2board_install.sh
```

#### 安装过程：

mysql安全配置脚本：
```shell
#输入root(mysql)的密码。默认没有，直接回车
Enter current password for root (enter for none):

#是否切换到unix套接字身份验证[Y/n]
Switch to unix_socket authentication [Y/n] n

#是否设置root密码
Change the root password? [Y/n]y
#如果选Y，就输入2次密码
New password:你的数据库密码
Re-enter new password:再次输入

#是否删除匿名用户?(就是空用户)，建议删除
Remove anonymous users? [Y/n]y

#是否不允许远程root登录,输y或回车
Disallow root login remotely? [Y/n]y

#是否删除test数据库，输y或回车
Remove test database and access to it? [Y/n]y

#是否加载权限使之生效，输y或回车
Reload privilege tables now? [Y/n]y
````

自定义数据库密码：

```shell
####################################################################
#                     欢迎使用V2board一键部署脚本                     #
#                      脚本适配环境Debian11+                        #
####################################################################

请输入Mysql数据库root密码:(自定义)
```

> 执行官方脚本安装过程需要执行yes
>
> ![y](https://cdn.jsdelivr.net/gh/gz1903/tu/a39ca9cd020e695f36612ed2dccdb0cb.png)

```shell
Running 2.0.13 (2021-04-27 13:11:08) with PHP 7.3.33 on Linux / 3.10.0-1160.el7.x86_64
Do not run Composer as root/super user! See https://getcomposer.org/root for details
Continue as root/super user [yes]? y
```

`需要拉取gitgub资源，国内网络较慢，或者下载失败，请确保网络通畅`



#### 输入安装信息：

数据库地址：localhost

数据库：v2board

数据库用户名：root

其他自定义。

```shell
__     ______  ____                      _  
\ \   / /___ \| __ )  ___   __ _ _ __ __| | 
 \ \ / /  __) |  _ \ / _ \ / _` | '__/ _` | 
  \ V /  / __/| |_) | (_) | (_| | | | (_| | 
   \_/  |_____|____/ \___/ \__,_|_|  \__,_| 

 请输入数据库地址（默认:localhost） [localhost]:
 > localhost

 请输入数据库名:
 > v2board

 请输入数据库用户名:
 > root

 请输入数据库密码:
 > 开始自定义的密码       

正在导入数据库请稍等...
数据库导入完成

 请输入管理员邮箱?:
 > v2board@qq.com

 请输入管理员密码?:
 > 自定义

一切就绪
访问 http(s)://你的站点/27b107f9 进入管理面板

```

#### 签发ssl证书
```shell
Saving debug log to /var/log/letsencrypt/letsencrypt.log

#输入邮箱地址
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): 你的邮箱地址

#阅读服务条款，必须同意选 y
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf. You must
agree in order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y

#向你发送新闻、活动等邮件，选择y,n都可以
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: n
Account registered.

#您希望为哪些名称激活HTTPS？选择用逗号和/或空格分隔的适当数字，回车选择所有项，输入C取消激活
Which names would you like to activate HTTPS for?
We recommend selecting either all domains, or all domains in a VirtualHost/server block.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: www.baidu.com
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel): 
Requesting a certificate for www.baidu.com

Successfully received certificate.
#证书保存在以下地址
Certificate is saved at: /etc/letsencrypt/live/www.baidu.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/www.baidu.com/privkey.pem
This certificate expires on 2024-04-17.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

#部署证书
Deploying certificate
Successfully deployed certificate for www.baidu.com to /etc/nginx/sites-enabled/v2board
Congratulations! You have successfully enabled HTTPS on https://www.baidu.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    13  100    13    0     0     50      0 --:--:-- --:--:-- --:--:--    50
```


#### 完成安装

```shell
--------------------------- 安装已完成 ---------------------------
##################################################################
#                            V2board                             #
##################################################################
 数据库用户名   :root
 数据库密码     :
 网站目录       :/usr/share/nginx/html/v2board 
 Nginx配置文件  :/etc/nginx/conf.d/v2board.conf 
 PHP配置目录    :/etc/php.ini 
 内网访问       :http://
 外网访问       :http://
 安装日志文件   :/var/log/V2board_install_2021-12-10_17:15:09.log
------------------------------------------------------------------
```


#### 主界面
![](https://cdn.jsdelivr.net/gh/gz1903/tu/0761a10fc7ec8db631493bf2ce455aad.png)
![ok](https://cdn.jsdelivr.net/gh/gz1903/tu/c1c18e8cb08ee3ad7b4ce73c5f06d0ee.png)
![ok](https://cdn.jsdelivr.net/gh/gz1903/tu/7f9d07a7d96dec7e07cf9de88c9e0c9a.png)
![ok](https://cdn.jsdelivr.net/gh/gz1903/tu/6c90fee3362f6874ea96f64fe469a2ab.png)
![ok](https://cdn.jsdelivr.net/gh/gz1903/tu/6c88a680e8bfd55e2c1d48f90839a8b7.png)
![ok](https://cdn.jsdelivr.net/gh/gz1903/tu/07d87e6ddbaa2a974f061ae282a2d970.png)

#### 前台登录界面：

![ok](https://cdn.jsdelivr.net/gh/gz1903/tu/30c58ac51674dc8df9a9f038302a1655.png)

#### 后台登录界面：

![ok](https://cdn.jsdelivr.net/gh/gz1903/tu/144e26a3abb8a0b452fc235aed2be168.png)

#### 前台界面：

![ok](https://cdn.jsdelivr.net/gh/gz1903/tu/5a7f75412aa261c360c3bf340e9a7246.png)
