#!/bin/bash
DATA_DIR="/mnt/e"
JAVA_DIR="$DATA_DIR/jdk1.8.0_231/bin"

if ! [ -d $DATA_DIR/$1 ]; then
  echo "Making a new server directory..."
  mkdir -p $DATA_DIR/$1
fi

if ! [ -f $DATA_DIR/$1/server.jar ]; then
  echo "Getting server.jar from minecraft.net..."
  SERVER_JAR=$(curl -s https://www.minecraft.net/en-us/download/server/ |grep server.jar |awk -F\" '{print $2}')
  wget -O $DATA_DIR/$1/server.jar $SERVER_JAR

fi

cd $DATA_DIR/$1
echo "Starting minecraft..."

if ! grep "eula=true" $DATA_DIR/$1/eula.txt; then
  echo "eula=true" > $DATA_DIR/$1/eula.txt
fi

$JAVA_DIR/java -Xmx8024M -Xms1024M -XX:+UseG1GC -jar server.jar nogui