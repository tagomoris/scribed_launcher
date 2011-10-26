#!/bin/bash

if [ ! -r /etc/scribe_admin.conf ]; then
    echo "Config file does not exists: /etc/scribe_admin.conf"
    exit 1
fi
#TODO rewrite all
source /etc/scribeline.conf

logfile=/var/log/scribe_line.log
scribe_line_sh=/usr/local/scribe_line/scribe_line.sh
scribe_line_py=/usr/local/scribe_line/scribe_line.py

prog=scribeline
lockfile=/var/run/scribe_line.run

RETVAL=0

CMD=$scribe_line_sh
SERVERS=""
NOHUPPATH="/usr/bin/nohup"

categories=()
logfilepaths=()
items=0

lines=$(echo "$LOGS" | wc -l)
for (( i = 0; i < $lines; i++ )); do
    j=$((i + 1))
    line=$(echo "$LOGS" | head -n $j | tail -1)
    if echo "$line" | egrep -q '^[[:space:]]*(#|$)'; then
        continue
    fi
    categories[$items]=$(echo $line | awk '{print $1};')
    logfilepaths[$items]=$(echo $line | awk '{print $2};')
    items=$((items + 1))
done

if [ $PYTHONPATH ]; then
    CMD="$scribe_line_sh -p $PYTHONPATH"
fi
if [ $SECONDARY_SERVER ]; then
    SERVERS="$PRIMARY_SERVER $SECONDARY_SERVER"
else
    SERVERS=$PRIMARY_SERVER
fi

start() {
    echo -n $"Starting $prog: "
    if [ x"$RUN" != "xtrue" ]; then
        echo "configured not to run."
        RETVAL=0
        return $RETVAL
    fi
    if [ -f $lockfile ]; then
        echo "already running."
        RETVAL=1
        return $RETVAL
    fi
    for (( i = 0; i < $items; i++ )); do
        $NOHUPPATH $CMD ${categories[$i]} ${logfilepaths[$i]} $SERVERS >> $logfile &
    done
    sleep 1
    procs=`ps auxww | grep $scribe_line_py | grep -v grep | wc -l`
    if [ $procs != $items ]; then
        echo "not started correctly."
        RETVAL=1
    else
        echo "ok."
        RETVAL=0
    fi
    [ $RETVAL = 0 ] && touch ${lockfile}
    return $RETVAL
}
stop() {
    echo -n $"Stopping $prog: "
    ps -ef | grep $scribe_line_sh | grep -v grep | awk '{print $2}' | xargs echo | sed -e 's/ /,/g' | while read x; do ps -f --pid $x --ppid $x; done | awk '{print $2;}' | grep -v PID | xargs kill -TERM
    sleep 1
    RETVAL=`ps auxww | grep $scribe_line_py | grep -v grep | wc -l`
    if [ $RETVAL = 0 ]; then
        rm -f ${lockfile}
        echo "ok."
    else
        echo "failed."
    fi
    return $RETVAL
}
reload() {
    echo -n $"Reloading $prog: "
    ps auxww | grep $scribe_line_py | grep -v grep | awk '{print $2}' | xargs kill -HUP
    echo "reset connections."
    echo "To run with new config file, do 'restart'."
    RETVAL=0
    return $RETVAL
}
status() {
    echo -n "Configured logs for $prog: $items, "
    procs=`ps auxww | grep $scribe_line_py | grep -v grep | wc -l`
    if [ $procs != $items ]; then
        echo "not running correctly."
        RETVAL=1
    else
        if [ $items = 0 ]; then
            echo "ok."
        else
            echo "running."
        fi
        RETVAL=0
    fi
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
  reload)
        reload
        ;;
  *)
        echo $"Usage: $prog {start|stop|restart|reload|status}"
        exit 1
esac

exit $RETVAL
