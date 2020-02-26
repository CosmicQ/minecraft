#!/bin/bash

if ! [ -d /mnt/e/$1 ]; then
  echo "Making a new server directory..."
  mkdir -p /mnt/e/$1
fi


if ! [ -f /mnt/e/$1/server.jar ]; then
  echo "Getting server.jar from minecraft.net..."
  SERVER_JAR=$(curl -s https://www.minecraft.net/en-us/download/server/ |grep server.jar |awk -F\" '{print $2}')
  wget -O /mnt/e/$1/server.jar $SERVER_JAR

fi

cd /mnt/e/$1
echo "Starting minecraft..."

if ! grep "eula=true" /mnt/e/$1/eula.txt; then
  echo "eula=true" > /mnt/e/$1/eula.txt
fi

/mnt/e/jdk1.8.0_231/bin/java -Xmx8024M -Xms1024M -XX:+UseG1GC -jar server.jar nogui