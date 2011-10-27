#!/bin/bash

if [ ! -r /etc/scribed_launcher.conf ]; then
    echo "Config file does not exists: /etc/scribed_launcher.conf"
    exit 1
fi

prog="scribed"
install_dir=/usr/local/scribed_launcher

scribed_path=/usr/local/bin/scribed
config_file=/etc/scribed.conf
username="root"
classpath=
logpath=/var/log/scribed.log
rotatelogs=
rotatelogs_args="86400"

nohup_path=$(which nohup)
# read configurations

# SCRIBED_PATH=/usr/local/bin/scribed
# CONFIG_FILE=/etc/scribed.conf
# USERNAME=root
# CLASSPATH=
# LOGPATH=/var/log/scribed.log
# ROTATELOGS=
# ROTATELOGS_ARGS=86400
. /etc/scribed_launcher.conf

[ -x "$SCRIBED_PATH" ] && scribed_path="$SCRIBED_PATH"
[ -r "$CONFIG_FILE" ] && config_file="$CONFIG_FILE"
if [ -n "$USERNAME" ] ; then
    cat /etc/passwd | awk -F: '{print $1;}' | grep -q "$USERNAME"
    if [ $? -ne 0 ]; then
        echo "USERNAME $USERNAME doesn't exits"
        exit 1
    fi
    username="$USERNAME"
fi
if [ -n "$CLASSPATH" ] ; then
    CLASSPATH_PATTERNS=$(echo "$CLASSPATH" | sed -e 's/:/ /g')
    classpath=`ls -1 $CLASSPATH_PATTERNS | perl -e '@jars=<STDIN>;chomp @jars;print join(":",@jars);'`
fi
[ -n "$LOGPATH" ] && logpath="$LOGPATH"
[ -x "$ROTATELOGS" ] && rotatelogs="$ROTATELOGS"
[ -n "$ROTATELOGS_ARGS" ] && rotatelogs_args="$ROTATELOGS_ARGS"

logdir=$(dirname $LOGPATH)
[ ! -d $logdir ] && mkdir -p $logdir

if [ ! -r "$config_file" ] ; then
    echo "scribed Config file does not exists: $config_file"
    exit 1
fi    
scribed_port=$(egrep -v '^[[:space:]]#' "$config_file" | grep '^port=' | head -1 | sed -e 's/^port=//')
if [ x"$scribed_port" = 'x' ] ; then
    scribed_port=1463
fi

RETVAL=0

proc_pids=$(ps axuww | grep $prog | grep -v grep | grep -v /etc/init.d | awk '{print $2;}')

start() {
    if [ -n "$proc_pids" ] ; then
        echo "scribed process already running, pid: $proc_pids"
        exit 1
    fi
    echo -n "Starting $prog: "

    if [ -z "$rotatelogs" ] ; then
        sudo -u "$username" CLASSPATH="$classpath" -i $nohup_path "$scribed_path" > "$logpath" &
    else
        sudo -u "$username" CLASSPATH="$classpath" -i $nohup_path "$scribed_path" | "$rotatelogs" "$logpath" $rotatelogs_args &
    fi
    sleep 1
    pid=$(ps axuww | grep $prog | grep -v grep | grep -v /etc/init.d | awk '{print $2;}')
    if [ -z "$pid" ]; then
        echo "not started correctly."
        RETVAL=1
    else
        echo "ok, pid $pid."
        RETVAL=0
    fi
    return $RETVAL
}
stop() {
    echo -n $"Stopping $prog: "
    $install_dir/bin/scribe_ctrl stop $scribed_port
    sleep 1
    pid=$(ps axuww | grep $prog | grep -v grep | grep -v /etc/init.d | awk '{print $2;}')
    if [ -n "$pid" ]; then
        echo "not stopped correctly, pid $pid"
        RETVAL=1
    else
        echo "ok."
        RETVAL=0
    fi
    return $RETVAL
}
status() {
    $install_dir/bin/scribe_ctrl status $scribed_port
    RETVAL=$?
    return $RETVAL
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  status)
        status
        ;;
  restart)
        stop && start
        ;;
  *)
        echo $"Usage: $prog {start|stop|restart|status}"
        exit 1
esac

exit $RETVAL
