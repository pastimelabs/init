# INIT
### The Pastime Labs server initialization tool
---
1. Set up new droplet
2. SSH in as `root`
3. clone the repo:

```
git clone git@github.com:pastimelabs/init.git
```

4. run it:

```
cd init
./init.sh
```

The script will ask for some details and then take care of the rest!

## What does it do?

It installs software:

* PostgreSQL 9.6
* Vim
* Git
* nginx
* fail2ban
* Let's Encrypt Certbot
* Redis
* RVM
* Ruby (specified version)
* Rails
* Bundler
* NodeJS 9.x
* Yarn

It sets acceptable basic security settings:

* Firewall blocking all incoming ports except 22, 80, 443
* SSH that disallows root login or passwords
* Automatic security-related software updates

It also sets the timezone and sets up a useful dynamic MOTD
