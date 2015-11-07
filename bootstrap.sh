#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
MYSQL_PASSWORD='root'
PROJECTFOLDER='/var/www/html'

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install apache 2.5 and wsgi
sudo apt-get install -y curl apache2 libapache2-mod-wsgi
sudo apt-get install python-setuptools
sudo apt-get install python-pip

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
sudo apt-get -y install mysql-server

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerName localhost

    ServerAdmin webmaster@localhost
    DocumentRoot "${PROJECTFOLDER}"

    <Directory "${PROJECTFOLDER}">
            AllowOverride All
    </Directory>
    WSGIScriptAlias / "${PROJECTFOLDER}/app.wsgi"
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

sed -i -e '0,/index/s//index.wsgi index/' /etc/apache2/mods-available/dir.conf

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git
