#! /bin/bash
#
#version-1.0
#user to run this script >> AWS ec2-user >> IF user root please remove sudo 
#Automatic install Apache, MySQL/MariaDB, PHP and wordpress install on AWS ec2 instance >>   


echo "==Going to install  Apache, MySQL, PHP and wordpress into an EC2 instance of Amazon AMI Linux.=="
echo "Want to Run the script? (y/n)"

read -e val
if [ "$val" == n ] ; then
     echo ".....quit installation...."
     exit
else
    sudo yum -y update
	#going to install 'expect' to input from keystrokes/y/n/passwords  
	echo "going to install 'expect' to input from keystrokes/ " 
	sudo yum -y install expect 
    echo "=======Done expect installation===========" 
	
	# Apache installation
	echo "going to install Apache" 
	sudo yum -y install httpd

	# Start Apache
	sudo service httpd start
    sudo systemctl enable httpd
	 
	# Install PHP
	sudo yum -y install php-cli php-pdo php-fpm php-json php-mysqlnd

	# Restart Apache
	sudo service httpd restart
     
	# Install MySQL  
	#yum -y install mysql-server  
	sudo yum -y install mariadb105-server

    # Start MySQL
    #service mysqld start
	
	sudo systemctl start mariadb
    sudo systemctl enable mariadb
	
    # Create a database named blog
    sudo mysqladmin -uroot create wordpress

    
	#non interactive mysql_secure_installation with a little help from expect.
	## login root user 
    sudo su
	SECURE_MYSQL=$(expect -c "
	 
			set timeout 10
			spawn mysql_secure_installation
			 
			expect \"Enter current password for root (enter for none):\"
			send \"\r\"
			 
			expect \"Change the root password?\"
			send \"y\r\"
			expect \"New password:\"
			send \"root\r\"
			expect \"Re-enter new password:\"
			send \"root\r\"
			expect \"Remove anonymous users?\"
			send \"y\r\"
			 
			expect \"Disallow root login remotely?\"
			send \"y\r\"
			 
			expect \"Remove test database and access to it?\"
			send \"y\r\"
			 
			expect \"Reload privilege tables now?\"
			send \"y\r\"
			 
			expect eof
	")
 
     echo "$SECURE_MYSQL"

     # Change directory to web root
	 cd /var/www/html

	# Download Wordpress
	wget http://wordpress.org/latest.zip

	# Extract Wordpress
	unzip latest.zip

	# Change directory to wordpress
	cd /var/www/html/wordpress/

	# Create a WordPress config file 
	mv wp-config-sample.php wp-config.php

	#set database details with perl find and replace
	sed -i "s/database_name_here/wordpress/g" /var/www/html/wordpress/wp-config.php
	sed -i "s/username_here/root/g" /var/www/html/wordpress/wp-config.php
	sed -i "s/password_here/root/g" /var/www/html/wordpress/wp-config.php

	#create uploads folder and set permissions
	mkdir wp-content/uploads
    chmod 777 wp-content/uploads

   #remove wp file
   rm -rf /var/www/html/latest.zip

   echo "check your site http://$(hostname)/wordpress/."

fi