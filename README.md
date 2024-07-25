# Holy Unblocker: Building & Deployment scripts

This repo contains scripts that are used to build the Holy Unblocker frontend and deploy backend code across 4 different servers.

## Contributions

Contributions are not being accepted at this time. Sorry.

## Setup

This guide assumes you have root.

### Across all servers:

This is ran on the master server and on each edge server

1. install dependencies

   ```sh
   sudo apt install git nginx rsync
   ```

2. delete the default config

   ```sh
   rm /etc/nginx/sites-enabled/default
   ```

3. install stub config

   ```sh
   echo "include /root/domains.conf;" > /etc/nginx/sites-enabled/domains.conf
   ```

4. Install NodeJS

   > You need at least NodeJS v17 to deploy Holy Unblocker.

   We recommend installing from [NodeSource](https://github.com/nodesource/distributions#table-of-contents), or using [Node Version Manager](https://github.com/nvm-sh/nvm#table-of-contents) to install the latest version.

   [Most distros usually have very outdated versions of NodeJS.](https://gist.github.com/e9x/b549f46081ce794914461f2fbb9566bd#file-nodejs-across-linux-distributions-md)

   Verify you're using NodeJS v17 or higher:

   ```sh
   node -v
   ```

5. Install [PM2](https://pm2.keymetrics.io/docs/usage/quick-start/)

6. setup the HU user

   ```
   adduser hu
   ```

### On your master server:

1. Install Rust nightly

   https://www.rust-lang.org/tools/install

2. Setup the master HU user

   ```
   su hu
   cd /home/hu/
   git clone https://github.com/holywebwork/website2.git
   git clone https://github.com/holywebwork/lander.git
   git clone https://github.com/MercuryWorkshop/epoxy-tls
   cd epoxy-tls/server
   cargo b -r
   exit
   ```

3. Checkout the repo

   ```sh
   git clone https://github.com/holywebwork/hu-util.git
   cd hu-util
   ```

4. Setup your configs

   Use a text editor like `nano` or `vim` to open these files.

   - domains.txt - contains a list of domains

   ```
   domain1.com
   domain2.com
   domain3.com
   ```

   - servers.txt - contains a list of edge server addresses

   ```
   my-server-a
   my-server-b
   my-server-c
   1.1.1.1
   1.2.3.4
   ```

5. Configure SSH

   You will need to generate a key on your master server and install the public key in each edge server.

   You can create custom hosts with configs in your `~/.ssh/config`

   ```
   Host hu-chicago
       User root
       HostName 1.1.1.1
       IdentityFile ~/.ssh/id_rsa
   ```

6. Run the scripts

   This will either work, or it will go horribly wrong.

   ```
   ./copy.sh
   ./update.sh
   ```
