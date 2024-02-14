#!/bin/bash

# Add Wordpress site
# Request domain name and create NGINX server block
echo "Please enter your domain name:"
read domain_name

sudo mkdir -p /var/www/$domain_name/html
sudo chown -R $USER:$USER /var/www/$domain_name/html
sudo chmod -R 755 /var/www/$domain_name

sudo tee /etc/nginx/sites-available/$domain_name <<EOF
server {
    listen 80;
    listen [::]:80;

    root /var/www/$domain_name/html;
    index index.html index.htm index.php;

    server_name $domain_name www.$domain_name;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/$domain_name /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Create MariaDB database and user
echo "Please enter your MariaDB root password:"
read db_root_password

echo "Please enter your desired WordPress database name:"
read db_name

echo "Please enter your desired WordPress database user:"
read db_user

echo "Please enter your desired WordPress database user password:"
read db_user_password

sudo mysql -uroot -p$db_root_password <<EOF
CREATE DATABASE $db_name;
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_user_password';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# Install the latest version of Wordpress
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo cp -a /tmp/wordpress/. /var/www/$domain_name/html
sudo chown -R www-data:www-data /var/www/$domain_name/html
# or make editable via sftp:
# sudo chown -R ubuntu:www-data /var/www/$domain_name/html
sudo find /var/www/$domain_name/html -type d -exec chmod 750 {} \;
sudo find /var/www/$domain_name/html -type f -exec chmod 640 {} \;

# Configure Wordpress with MariaDB
sudo mv /var/www/$domain_name/html/wp-config-sample.php /var/www/$domain_name/html/wp-config.php
sudo sed -i "s/database_name_here/$db_name/" /var/www/$domain_name/html/wp-config.php
sudo sed -i "s/username_here/$db_user/" /var/www/$domain_name/html/wp-config.php
sudo sed -i "s/password_here/$db_user_password/" /var/www/$domain_name/html/wp-config.php
sudo sed -i "s/localhost/localhost:3306/" /var/www/$domain_name/html/wp-config.php

echo "WordPress has been installed and configured successfully!"

# Run Certbot to get SSL certificates and enable HTTPS
sudo certbot --nginx -d $domain_name -d www.$domain_name

echo "SSL certificate obtained and HTTPS enabled successfully!"

exit 0
