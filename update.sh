#!/bin/bash

# frontend
sudo -u hu bash -c "cd /home/hu/website2;\
git pull;\
npm i;\
npm run build;\
pm2 restart holy"

# landing page
sudo -u hu bash -c "cd /home/hu/lander;\
git pull;\
npm i;\
npm run build"
