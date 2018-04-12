#!/bin/bash

if ! [ $(id -u) = 0 ]; then
   echo "Sorry, you need to run INIT as root."
   exit 1
fi

cat << "HERE"
 ______   __  __  ______  ______
/\__  _\ /\ \/\ \/\__  _\/\__  _\
\/_/\ \/ \ \ `\\ \/_/\ \/\/_/\ \/
   \ \ \  \ \ , ` \ \ \ \   \ \ \
    \_\ \__\ \ \`\ \ \_\ \__ \ \ \
    /\_____\\ \_\ \_\/\_____\ \ \_\
    \/_____/ \/_/\/_/\/_____/  \/_/
HERE
echo ""
echo "Welcome to INIT, the Pastime Labs server setup utility."
echo ""
echo "I need to gather some info."
read -p "App Name: " app_name
read -p "Deployer username: " username
stty -echo
read -p "Deployer password: " password
stty echo
read "Ruby version: " ruby_ver
echo ""
echo ""
echo "Thanks, let's get started!"
echo ""
echo "Installing software..."
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo add-apt-repository ppa:certbot/certbot
apt update
apt upgrade -y
apt install build-essential vim curl git-core nginx gnupg2 wget software-properties-common unattended-upgrades apticron fail2ban lsb-release figlet update-motd postgresql-9.6 postgresql-contrib libpq-dev python-certbot-nginx -y
echo ""
echo "Setting up Deployer..."
adduser $username --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$username:$password" | chpasswd
mkdir /home/$username/.ssh
cp /root/authorized_keys /home/$username/.ssh/
chown -R $username:$username /home/$username/.ssh/
chmod 700 /home/$username/.ssh/
echo ""
echo "Setting up SSH..."
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "AllowUsers $username" >> /etc/ssh/sshd_config
systemctl reload ssh
echo ""
echo "Setting up firewall..."
ufw allow OpenSSH
ufw allow http
ufw allow https
ufw enable
ufw status
echo ""
echo "Setting up automated updates..."
rm /etc/apt/apt.conf.d/50unattended-upgrades
rm /etc/apt/apt.conf.d/20auto-upgrades
rm /etc/apticron/apticron.conf
cp ./templates/auto-upgrades/50unattended-upgrade /etc/apt/apt.conf.d/
cp ./templates/auto-upgrades/20auto-upgrades /etc/apt/apt.conf.d/
echo "EMAIL=stevepaulo@gmail.com" >> /etc/apticron/apticron.conf
echo ""
echo "Setting up Dynamic MOTD..."
mkdir /etc/update-motd.d
cp ./templates/dynamic-motd/* /etc/update-motd.d/
chmod +x /etc/update-motd.d/*
echo ""
echo "Setting timezone..."
timedatectl set-timezone America/Los_Angeles
su - $username
cd
echo ""
echo "Setting up RVM and Ruby $ruby_ver..."
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm requirements
rvm install $ruby_ver
rvm use $ruby_ver --default
rvm rubygems current
echo ""
echo "Installing Rails and Bundler..."
gem install rails bundler --no-ri --no-rdoc -V
echo ""
echo "Setting up NodeJS and Yarn..."
curl -sL https://deb.nodesource.com/setup_9.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install nodejs yarn -y
echo ""
echo "I think that's it......."
echo "Bye!"