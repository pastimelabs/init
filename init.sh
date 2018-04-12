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
echo ""
read -p "Ruby version: " ruby_ver
echo ""
echo "Thanks, let's get started!"

echo ""
echo "#### Installing software..."
echo ""

add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
add-apt-repository ppa:certbot/certbot -y
apt update
apt upgrade -y
apt install build-essential vim curl git-core nginx gnupg2 wget software-properties-common unattended-upgrades apticron fail2ban lsb-release figlet update-motd postgresql-9.6 postgresql-contrib libpq-dev python-certbot-nginx -y
apt autoremove -y

echo ""
echo "#### Setting up Deployer..."
echo ""

adduser $username --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$username:$password" | chpasswd
mkdir /home/$username/.ssh
cp /root/.ssh/authorized_keys /home/$username/.ssh/
chown -R $username:$username /home/$username/.ssh/
chmod 700 /home/$username/.ssh/

echo ""
echo "#### Setting up SSH..."
echo ""

sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
echo "" >> /etc/ssh/sshd_config
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "AllowUsers $username" >> /etc/ssh/sshd_config
systemctl reload ssh

echo ""
echo "#### Setting up firewall..."
echo ""
ufw allow OpenSSH
ufw allow http
ufw allow https
ufw --force enable
ufw status

echo ""
echo "#### Setting up automated updates..."
echo ""
rm /etc/apt/apt.conf.d/50unattended-upgrades
rm /etc/apt/apt.conf.d/20auto-upgrades
rm /etc/apticron/apticron.conf
cp ./templates/auto-upgrades/50unattended-upgrades /etc/apt/apt.conf.d/
cp ./templates/auto-upgrades/20auto-upgrades /etc/apt/apt.conf.d/
echo "EMAIL=stevepaulo@gmail.com" >> /etc/apticron/apticron.conf

echo ""
echo "#### Setting up Dynamic MOTD..."
echo ""
rm -rf /etc/update-motd.d/
mkdir /etc/update-motd.d
cp ./templates/dynamic-motd/* /etc/update-motd.d/
chmod +x /etc/update-motd.d/*

echo ""
echo "#### Setting timezone..."
echo ""
timedatectl set-timezone America/Los_Angeles

echo ""
echo "#### Setting up RVM and Ruby $ruby_ver..."
echo ""
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm
rvm requirements
rvm install $ruby_ver
rvm use $ruby_ver --default
rvm rubygems current
usermod -aG rvm $username

echo ""
echo "#### Installing Rails and Bundler..."
echo ""
gem install rails bundler --no-ri --no-rdoc

echo ""
echo "#### Setting up NodeJS and Yarn..."
echo ""
curl -sL https://deb.nodesource.com/setup_9.x -o nodesource_setup.sh
bash nodesource_setup.sh
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt update
apt install nodejs yarn -y

echo ""
echo ""
echo ""
echo "I think that's it......."
echo "Bye!"
