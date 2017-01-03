#!/usr/bin/env bash
function append_redsocks_conf {
  local type=$1
  local ip=$2
  local port=$3
  local local_port=$4
  if [ -z "$type" -o -z "$ip" -o -z "$port" -o -z "$local_port" ] ; then
    echo missing required parameter >&2
    exit 1
  fi
  (cat <<EOF
redsocks {
  type = $type;
  ip = $ip;
  port = $port;
  local_ip = 127.0.0.1;
  local_port = $local_port;
  splice = false;
}
EOF
) >> /tmp/redsocks.conf
}

function parse_ip {
  echo $1 | sed -nE "s/^http(s)?:\/\/(.+):([0-9]+)$/\2/p"
}

function parse_port {
  echo $1 | sed -nE "s/^http(s)?:\/\/(.+):([0-9]+)$/\3/p"
}

if [ $# -eq 1 ]; then
	http_proxy=${http_proxy:-$1}
	https_proxy=${https_proxy:-$1}
fi

if [ ! -z "$http_proxy" ] ; then
  ip=$(parse_ip $http_proxy)
  port=$(parse_port $http_proxy)
  append_redsocks_conf "http-relay" $ip $port "12345"
  echo
  echo "run the following command to redirect port 80 traffic the http proxy:"
  echo -e "\tiptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 12345"
  echo
fi

if [ ! -z "$https_proxy" ] ; then
  ip=$(parse_ip $https_proxy)
  port=$(parse_port $https_proxy)
  append_redsocks_conf "http-connect" $ip $port "12346"
  echo
  echo "run the following command to redirect port 443 traffic the https proxy:"
  echo -e "\tiptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to 12346"
  echo
fi

exec /usr/bin/redsocks -c /tmp/redsocks.conf
