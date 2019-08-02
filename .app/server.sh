#!/bin/bash
# simple web server loader script, which depends on Busybox only

# Usage:    server start|stop|-h|--help
#

print_usage() {
  echo "Usage:"
  echo
  echo "  server start|stop|-h"
  echo
  return 1
}

if [ "$1" = '-h' ] || [ "$1" = '--help' ];then
  print_usage
  exit 1
fi

if [ "$1" = "stop" ];then
  # kill server (if running) and output message
  kill $(cat /tmp/httpd_pid_nobody) 2>/dev/null \
    && echo "Server stopped." \
    || echo "Server not running."
  exit 0
fi

# the only other option accepted is 'start', if we didnt get it, exit
if [ "$1" != "start" ];then
  print_usage
  exit 1
fi


# load the blog config, to get $blog_url, etc
[ -f .site_config ] && source .site_config

# work out where to start the server from
OLD_IFS=$IFS
IFS=/
path=''
for val in $blog_url
do
  [ "$val" = "" ] && continue
  path="${path}../"
done
IFS=$OLD_IFS

# set the web root (the dir from which the web server is started)
webroot="$path"

portnum="${2:-8080}"

# create $webroot if needed
[ "$webroot" != "."  ] && \
[ "$webroot" != ".." ] && \
[  ! -d "$webroot"   ] && \
  mkdir -p "$webroot" 2>/dev/null

chown -R nobody:nobody "$(realpath "$webroot")"

httpd=$(which httpd)

if [ "$httpd" = "" ];then
  echo "Error: command 'httpd' not installed."
  exit 1
fi

# run the webserver with a restricted environment, allowing only a limited
# set of variables to be exposed to the webserver:
#
#   env -           reset/clear the environment
#   PATH            paths to commands (obviously)
#   DOCUMENT_ROOT   the web root folder (needed/expected by many scripts)
#   SERVER_NAME     the host name of the server, may be dot-decimal IP address
#   SERVER_PORT     the port being used by the server

echo "env - \
  PATH=\"$PATH\" \
  DOCUMENT_ROOT=\"$webroot\" \
  SERVER_NAME=${server_name:-localhost} \
  SERVER_PORT=$portnum \
  $httpd \
    -p 127.0.0.1:${portnum} \
    -h \"${webroot}\"

" > /tmp/httpd_cmd

rm /tmp/httpd_err &>/dev/null

# run the web server as user 'nobody'
su -pm nobody -c "$(cat /tmp/httpd_cmd) 2>/tmp/httpd_err" &

sleep 0.2

# exit if server already running
grep 'already in use' /tmp/httpd_err &>/dev/null \
  && echo "Server already running." \
  && echo "Use \`server stop\` to kill it." \
  && exit 1

# get the PID of the running web server
httpd_pid=$(ps -e | grep httpd | cut -f1 -d' ')

if [ "$httpd_pid" = "" ];then
  httpd_pid=$(ps | grep httpd | grep -v grep | cut -f2 -d' ')
fi

if [ "$httpd_pid" = "" ];then
  httpd_pid=$(ps | grep httpd | grep -v grep | cut -f1 -d' ')
fi

# save pid to file (usedby `server stop`)
echo -n $httpd_pid > /tmp/httpd_pid_nobody

# final msg
#echo '  => busybox httpd -p localhost:'$portnum' -h "'$webroot'" -u nobody:nobody &'
#echo
echo "Started server in $(realpath ${webroot:-/var/www}) (pid $httpd_pid)"
echo
echo "Visit http://${server_name:-localhost}:${portnum}${blog_url} in your browser."
echo
echo "You can stop the server using:"
echo "  server stop"

# clean up
unset dir
unset portnum
unset httpd
unset httpd_pid
unset host_name

exit 0
