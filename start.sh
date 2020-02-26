#!/bin/bash
DIR="/mnt/e"

if ! [ -d $DIR/$1 ]; then
  echo "Making a new server directory..."
  mkdir -p $DIR/$1
fi

if ! [ -f $DIR/$1/server.jar ]; then
  echo "Getting server.jar from minecraft.net..."
  SERVER_JAR=$(curl -s https://www.minecraft.net/en-us/download/server/ |grep server.jar |awk -F\" '{print $2}')
  wget -O $DIR/$1/server.jar $SERVER_JAR

fi

cd $DIR/$1
echo "Starting minecraft..."

if ! grep "eula=true" $DIR/$1/eula.txt; then
  echo "eula=true" > $DIR/$1/eula.txt
fi

$DIR/jdk1.8.0_231/bin/java -Xmx8024M -Xms1024M -XX:+UseG1GC -jar server.jar nogui