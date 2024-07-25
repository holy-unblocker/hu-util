#!/bin/bash
# edge files belong to `hu`
#edge=/root/hu-util/edge

. build-domains.sh

mapfile -t servers < servers.txt

# copy live certbot certs
rm -rf $edge/certbot/
mkdir -p $edge/certbot/{live,archive}
cp -r /root/certbot/{live,archive} $edge/certbot
cp -r $edge/certbot /etc/nginx/

cp /home/hu/epoxy-tls/target/release/epoxy-server $edge

startcmd="/usr/sbin/nginx -t;\
systemctl restart nginx;\
cd /home/hu/edge;\
sudo -u hu pm2 start;\
cd /root/;\
rm -rf /etc/nginx/certbot;\
mv /home/hu/edge/certbot /etc/nginx/certbot;\
chmod -R 0644 /etc/nginx/certbot"

echo "[host] Deploying edge"
bash $startcmd
echo "[host] Done"

for i in "${servers[@]}"
do
  echo "[$i] Downloading edge data"
  rsync --delete --recursive --archive --compress $edge "$i:/home/hu/edge/"
  echo "[$i] Deploying edge"
  ssh $i $startcmd
  echo "[$i] Done"
done

rm -rf $edge/certbot
