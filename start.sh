#!/bin/bash
DATA_DIR="/mnt/e"
JAVA_DIR="$DATA_DIR/jdk1.8.0_231/bin"

# If we didn't add a data directory, bail and complain
if [ -z $1 ]; then
  echo "You need to add a data directory (or world) to start"
  exit 2
fi

# Make data directory if it doesn't exist
if ! [ -d $DATA_DIR/$1 ]; then
  echo "Making a new server directory..."
  mkdir -p $DATA_DIR/$1 || { echo "Unable to create the data directory"; exit 2; }
fi

# Get server download info from minecraft.net
SERVER_RAW=$( /usr/bin/curl -s https://www.minecraft.net/en-us/download/server/ )
SERVER_JAR=$( grep server.jar <<<$SERVER_RAW | awk -F\" '{print $2}' )
SERVER_VER=$( grep server.jar <<<$SERVER_RAW | awk -F\> '{print $2}' | awk -F\< '{print $1}' )

# Function to download the server.jar file
get_server () {
  echo "Getting server.jar from minecraft.net..."
  /usr/bin/wget --quiet -O $DATA_DIR/$1/server.jar $SERVER_JAR  || { echo "Download failed"; exit 3; }
  echo "Writing version to $DATA_DIR/$1/server.version"
  echo "$SERVER_VER" > $DATA_DIR/$1/server.version || { echo "Write server version failed, permissions?"; exit 4; }
}

# Check to see if the server.jar file exists
if ! [ -f $DATA_DIR/$1/server.jar ]; then
  # If no server.jar, get one
  get_server
else
  # Check to see if there is a new version
  echo "Checking for version update..."
  if ! [ $SERVER_VER == `cat $DATA_DIR/$1/server.version` ]; then
    # Version mismatch - get new version
    echo "Version mismatch - getting new version"
    get_server
  else
    # Version is the same, do nothing
    echo "Version is the same, skipping update"
  fi
fi

# Check to see if the EULA has been agreed to
if [[ `grep "eula=true" $DATA_DIR/$1/eula.txt` != *eula\=true* ]]; then
  echo "Accepting the EULA..."
  echo "eula=true" > $DATA_DIR/$1/eula.txt || { echo "Write EULA failed, permissions?"; exit 5; }
fi

# Start Minecraft
cd $DATA_DIR/$1
echo "Starting minecraft..."
$JAVA_DIR/java -Xmx8024M -Xms1024M -XX:+UseG1GC -jar server.jar nogui || { echo "Unable to run server...  shrug."; exit 6; }