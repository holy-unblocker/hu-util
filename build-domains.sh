#!/bin/bash
mapfile -t domains < domains.txt

# edge files belong to the `hu` user
export edge=/root/hu-util/edge/
edge_domain_conf=$edge/domains.conf
master_domain_conf=/root/domains.conf

upgrader="# Upgrade all HTTP traffic to HTTPS
server {
    listen 80 default_server;
    server_name _;
    return 301 https://\$host\$request_uri;
}
"

dropper="# Drop all unknown traffic
server {
  server_name _;
  listen 443 ssl http2 default_server;
  ssl_certificate /etc/ssl/nginx/cert.pem;
  ssl_certificate_key /etc/ssl/nginx/key.pem;
  # reset connection
  return 444;
}
"

rm -rf /var/www/holyweb.work/
cp -r /home/hu/lander/dist/ /var/www/holyweb.work/

holywebwork="# Lander
server {
  listen 443 ssl http2;
  server_name holyweb.work;
  root /var/www/holyweb.work/;
  index index.html;
  ssl_certificate /etc/nginx/certbot/live/holyweb.work/fullchain.pem;
  ssl_certificate_key /etc/nginx/certbot/live/holyweb.work/privkey.pem;
}
"

echo "# EDGE: automatically generated on $(date)
$dropper$upgrader" > $edge_domain_conf
echo "# MASTER: automatically generated on $(date)
$dropper$upgrader$holywebwork" > $master_domain_conf

for i in "${domains[@]}"
do
  echo "building configs for $i"
  echo "
server {
  listen 443 ssl http2;
  server_name $i;
  ssl_certificate /etc/nginx/certbot/live/$i/fullchain.pem;
  ssl_certificate_key /etc/nginx/certbot/live/$i/privkey.pem;
  location / {
    proxy_pass http://localhost:8080;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \"upgrade\";
    proxy_read_timeout 86400;
  }
}" >> $master_domain_conf

  echo "
server {
  listen 443 ssl http2;
  server_name api.$i;
  ssl_certificate /etc/nginx/certbot/live/$i/fullchain.pem;
  ssl_certificate_key /etc/nginx/certbot/live/$i/privkey.pem;
  location / {
    proxy_pass http://localhost:4000;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \"upgrade\";
    proxy_read_timeout 86400;
  }
}" >> $edge_domain_conf
done

cat $edge_domain_conf
echo "Finished building $domainconf";
