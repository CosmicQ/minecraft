#!/bin/bash
DATA_DIR="/mnt/e"
JAVA_DIR="$DATA_DIR/jdk1.8.0_231/bin"

if ! [ -d $DATA_DIR/$1 ]; then
  echo "Making a new server directory..."
  mkdir -p $DATA_DIR/$1
fi

SERVER_RAW=$( /usr/bin/curl -s https://www.minecraft.net/en-us/download/server/ | grep server.jar )
SERVER_JAR=$( echo $SERVER_RAW | awk -F\" '{print $2}' )
SERVER_VER=$( echo $SERVER_RAW | awk -F\> '{print $2}' | awk -F\< '{print $1}' )

# If no server.jar, get one
if ! [ -f $DATA_DIR/$1/server.jar ]; then
  echo "Getting server.jar from minecraft.net..."
  /usr/bin/wget --quiet -O $DATA_DIR/$1/server.jar $SERVER_JAR
  echo "Writing version to $DATA_DIR/$1/server.version"
  echo "$SERVER_VER" > $DATA_DIR/$1/server.version
else
  echo "Checking for version update..."
  if ! [ $SERVER_VER == `cat $DATA_DIR/$1/server.version` ]; then
    # Version mismatch - get new version
    /usr/bin/wget --quiet -O $DATA_DIR/$1/server.jar $SERVER_JAR
    echo "Writing version to $DATA_DIR/$1/server.version"
    echo "$SERVER_VER" > $DATA_DIR/$1/server.version
  else
    echo "Version is the same, skipping update"
  fi
fi

cd $DATA_DIR/$1
echo "Starting minecraft..."

if [[ `grep "eula=true" $DATA_DIR/$1/eula.txt` != *eula\=true* ]]; then
  echo "Accepting the EULA..."
  echo "eula=true" > $DATA_DIR/$1/eula.txt
fi

$JAVA_DIR/java -Xmx8024M -Xms1024M -XX:+UseG1GC -jar server.jar nogui