#!/bin/sh

# The MIT License (MIT)
# 
# Copyright (c) 2016 River Yang
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Interactive service installer for redis server
# this generates a redis config file and an /etc/init.d script, and installs them
# this scripts should be run as root

die () {
echo "ERROR: $1. Aborting!"
exit 1
}

#Initial defaults
REDIS_RENAME_CONF=/data/redis-cluster/configs/rename-commands.conf

_REDIS_PORT=7000

echo "Welcome to the redis service installer"
echo "This script will help you easily set up a running redis server

"

#check for root user TODO: replace this with a call to "id"
if [ `whoami` != "root" ] ; then
echo "You must run this script as root. Sorry!"
exit 1
fi

#Read the redis port
read  -p "Please select the redis port for this instance: [$_REDIS_PORT] " REDIS_PORT
if [ ! `echo $REDIS_PORT | egrep "^[0-9]+\$"`  ] ; then
echo "Selecting default: $_REDIS_PORT"
REDIS_PORT=$_REDIS_PORT
fi

#read the redis config file
_REDIS_CONFIG_FILE="/data/redis-cluster/$REDIS_PORT/redis.conf"
read -p "Please select the redis config file name [$_REDIS_CONFIG_FILE] " REDIS_CONFIG_FILE
if [ !"$REDIS_CONFIG_FILE" ] ; then
REDIS_CONFIG_FILE=$_REDIS_CONFIG_FILE
echo "Selected default - $REDIS_CONFIG_FILE"
fi
#try and create it
mkdir -p `dirname "$REDIS_CONFIG_FILE"` || die "Could not create redis config directory"

#Read the redis cluster config file
_CLUSTER_FILE="/data/redis-cluster/$REDIS_PORT/nodes.conf"
read  -p "Please select the redis cluster config file for this instance: [$_CLUSTER_FILE] " CLUSTER_FILE
if [ !"$CLUSTER_FILE"  ] ; then
        CLUSTER_FILE=$_CLUSTER_FILE
        echo "Selected default - $CLUSTER_FILE"
fi

#read the redis log file path
_REDIS_LOG_FILE="/data/redis-cluster/$REDIS_PORT/redis.log"
read -p "Please select the redis log file name [$_REDIS_LOG_FILE] " REDIS_LOG_FILE
if [ !"$REDIS_LOG_FILE" ] ; then
REDIS_LOG_FILE=$_REDIS_LOG_FILE
echo "Selected default - $REDIS_LOG_FILE"
fi

#get the redis data directory
_REDIS_DATA_DIR="/data/redis-cluster/$REDIS_PORT"
read -p "Please select the data directory for this instance [$_REDIS_DATA_DIR] " REDIS_DATA_DIR
if [ !"$REDIS_DATA_DIR" ] ; then
REDIS_DATA_DIR=$_REDIS_DATA_DIR
echo "Selected default - $REDIS_DATA_DIR"
fi
mkdir -p $REDIS_DATA_DIR || die "Could not create redis data directory"

#get the redis executable path
_REDIS_EXECUTABLE=`which redis-server`
read -p "Please select the redis executable path [$_REDIS_EXECUTABLE] " REDIS_EXECUTABLE
if [ ! -f "$REDIS_EXECUTABLE" ] ; then
REDIS_EXECUTABLE=$_REDIS_EXECUTABLE

if [ ! -f "$REDIS_EXECUTABLE" ] ; then
echo "Mmmmm...  it seems like you don't have a redis executable. Did you run make install yet?"
exit 1
fi

fi

#render the tmplates
TMP_FILE="/tmp/$REDIS_PORT.conf"
DEFAULT_CONFIG="./redis.conf"
INIT_TPL_FILE="./redis_init_script.tpl"
INIT_SCRIPT_DEST="/etc/init.d/redis_cluster_$REDIS_PORT"
PIDFILE="/var/run/redis_cluster_$REDIS_PORT.pid"

#check the default for redis cli
CLI_EXEC=`which redis-cli`
if [ ! "$CLI_EXEC" ] ; then
CLI_EXEC=`dirname $REDIS_EXECUTABLE`"/redis-cli"
fi

#Generate config file from the default config file as template
#changing only the stuff we're controlling from this script
echo "## Generated by hotpu_install_server.sh ##" > $TMP_FILE

SED_EXPR="s#^port [0-9]{4}\$#port ${REDIS_PORT}#; \
s#^logfile .+\$#logfile ${REDIS_LOG_FILE}#; \
s#^dir .+\$#dir ${REDIS_DATA_DIR}#; \
s#^pidfile .+\$#pidfile ${PIDFILE}#; \
s#^cluster-config-file .+\$#cluster-config-file ${CLUSTER_FILE}#; \
s#^daemonize no\$#daemonize yes#;"
#echo $SED_EXPR
sed -r "$SED_EXPR" $DEFAULT_CONFIG  >> $TMP_FILE

#cat $TPL_FILE | while read line; do eval "echo \"$line\"" >> $TMP_FILE; done
cp -f $TMP_FILE $REDIS_CONFIG_FILE || exit 1

#Generate sample script from template file
rm -f $TMP_FILE

#we hard code the configs here to avoid issues with templates containing env vars
#kinda lame but works!
REDIS_INIT_HEADER=\
"#/bin/sh\n
#Configurations injected by install_server below....\n
EXEC=$REDIS_EXECUTABLE\n
CLIEXEC=$CLI_EXEC\n
PIDFILE=$PIDFILE\n
CONF=\"$REDIS_CONFIG_FILE\"\n
REDISPORT=\"$REDIS_PORT\"\n
###############\n"

REDIS_CHKCONFIG_INFO=\
"# REDHAT chkconfig header
# chkconfig: - 58 74
# description: redis_cluster_7000 is the redis daemon.
### BEGIN INIT INFO
# Provides: redis_6379
# Required-Start: $network $local_fs $remote_fs
# Required-Stop: $network $local_fs $remote_fs
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Should-Start: $syslog $named
# Should-Stop: $syslog $named
# Short-Description: start and stop redis_cluster_7000
# Description: Redis daemon
### END INIT INFO"

if [ !`which chkconfig` ] ; then
#combine the header and the template (which is actually a static footer)
echo "#/bin/sh" > $TMP_FILE || die "Could not write init script to $TMP_FILE"
echo "EXEC=$REDIS_EXECUTABLE" >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
echo "CLIEXEC=$CLI_EXEC" >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
echo "PIDFILE=$PIDFILE" >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
echo "CONF=\"$REDIS_CONFIG_FILE\""  >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
echo "REDISPORT=\"$REDIS_PORT\"" >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
cat $INIT_TPL_FILE >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
else
#if we're a box with chkconfig on it we want to include info for chkconfig
echo "#/bin/sh" > $TMP_FILE || die "Could not write init script to $TMP_FILE"
        echo "EXEC=$REDIS_EXECUTABLE" >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
        echo "CLIEXEC=$CLI_EXEC" >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
        echo "PIDFILE=$PIDFILE" >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
        echo "CONF=\"$REDIS_CONFIG_FILE\""  >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
        echo "REDISPORT=\"$REDIS_PORT\"" >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
        echo -e $REDIS_CHKCONFIG_INFO >> $TMP_FILE
cat $INIT_TPL_FILE >> $TMP_FILE || die "Could not write init script to $TMP_FILE"
fi

#copy to /etc/init.d
cp -f $TMP_FILE $INIT_SCRIPT_DEST && chmod +x $INIT_SCRIPT_DEST || die "Could not copy redis init script to  $INIT_SCRIPT_DEST"
#echo "Copied $TMP_FILE => $INIT_SCRIPT_DEST"

#Install the service
echo "Installing service..."

#if [ !`which chkconfig` ] ; then
#if we're not a chkconfig box assume we're able to use update-rc.d
# update-rc.d redis_$REDIS_PORT defaults && echo "Success!"
#else
# we're chkconfig, so lets add to chkconfig and put in runlevel 345
# chkconfig --add redis_$REDIS_PORT && echo "Successfully added to chkconfig!"
# chkconfig --level 345 redis_$REDIS_PORT on && echo "Successfully added to runlevels 345!"
#fi

if [ ! -f "$REDIS_RENAME_CONF" ] ; then
touch $REDIS_RENAME_CONF
echo "rename-command BGREWRITEAOF 184378976dd037a116ad43eb0caa25e0" > $REDIS_RENAME_CONF
echo "rename-command BGSAVE 06e8cc9eedfccaba69d779fa6258b634" >> $REDIS_RENAME_CONF
echo "rename-command CONFIG a31b1efa1fc56cf918c87daa6b5c409a" >> $REDIS_RENAME_CONF
echo "rename-command DEBUG bd8c226fa4077252b989607b06a32a95" >> $REDIS_RENAME_CONF
echo "rename-command FLUSHALL c8268425223806ae5a7c125f964d1f7e" >> $REDIS_RENAME_CONF
echo "rename-command FLUSHDB 527026b5d22290facac96d4b789a07b4" >> $REDIS_RENAME_CONF
echo "rename-command MONITOR 22e39576fe309be338430ca221a80c9e" >> $REDIS_RENAME_CONF
echo "rename-command SAVE e7593dc085dcafcba32663f29e60d80d" >> $REDIS_RENAME_CONF
#echo "rename-command SHUTDOWN 749c89d83cf6dbb382399aa87b7776dc" >> $REDIS_RENAME_CONF
echo "rename-command SLAVEOF c0ada6cc6b7820f37a7750d8c09ca939" >> $REDIS_RENAME_CONF
chmod 600 $REDIS_RENAME_CONF
echo "create a rename-commands file: [$REDIS_RENAME_CONF]"
fi
#/etc/init.d/redis_$REDIS_PORT start || die "Failed starting service..."

#tada
echo "Installation successful!"
exit 0
