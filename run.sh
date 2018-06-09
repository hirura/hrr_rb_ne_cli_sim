#!/bin/sh

_dir=$(cd $(dirname $0) && pwd)


start()
{
        if pgrep -f "ruby ne_cli_sim.rb" >/dev/null 2>&1
        then
                echo "Failed: ne_cli_sim is already running."
                exit 1
        fi

        (cd $_dir && nohup ruby ne_cli_sim.rb >/dev/null 2>&1 </dev/null &) >/dev/null 2>&1
}

stop()
{
        if ! pgrep -f "ruby ne_cli_sim.rb" >/dev/null 2>&1
        then
                echo "Failed: ne_cli_sim is not running."
                exit 1
        fi

        pkill -TERM -f "ruby ne_cli_sim.rb" >/dev/null 2>&1
}

forcestop()
{
        pkill -KILL -f "ruby ne_cli_sim.rb" >/dev/null 2>&1
}

status()
{
        if pgrep -f "ruby ne_cli_sim.rb" >/dev/null 2>&1
        then
                echo "ne_cli_sim is running."
        else
                echo "ne_cli_sim is not running."
        fi
}


case "$1" in
        start)
                if [ $# -ne 1 ]
                then
                        echo $"Usage: $0 start"
                        exit 1
                fi
                start
                ;;
        stop)
                if [ $# -ne 1 ]
                then
                        echo $"Usage: $0 stop"
                        exit 1
                fi
                stop
                ;;
        forcestop)
                if [ $# -ne 1 ]
                then
                        echo $"Usage: $0 forcestop"
                        exit 1
                fi
                forcestop
                ;;
        status)
                if [ $# -ne 1 ]
                then
                        echo $"Usage: $0 status"
                        exit 1
                fi
                status
                ;;
        *)
                echo $"Usage: $0 {start|stop|forcestop|status}"
esac
