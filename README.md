# INIT
## The Pastime Labs server initialization tool
---
1. Set up new droplet
2. SSH in as root
3. set up RSA key pair:

```
ssh-keygen
```

4. `cat` the public key, copy it and add it to GitHub
5. clone the repo

```
git clone git@github.com:stevepaulo/init.git
```

6. run it.

```
cd init
./init.sh
```

The script will ask for some details an then take care of the rest!