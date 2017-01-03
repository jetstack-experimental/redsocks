#!/usr/bin/env bash
function parse_ip {
  echo "${1}" | sed -nE "s/^http(s)?:\/\/(.+):([0-9]+)$/\2/p"
}

function parse_port {
  echo "${1}" | sed -nE "s/^http(s)?:\/\/(.+):([0-9]+)$/\3/p"
}

if [ $# -eq 1 ]; then
	http_proxy=${http_proxy:-$1}
	https_proxy=${https_proxy:-$1}
fi

if [ ! -z "$http_proxy" ] ; then
  ip=$(parse_ip "${http_proxy}")
  port=$(parse_port "${http_proxy}")
  (cat <<EOF
redsocks {
  type = http-relay;
  ip = $ip;
  port = $port;
  local_ip = 127.0.0.1;
  local_port = 12345;
  listenq = 512;
}
EOF
) >> /tmp/redsocks.conf
  echo
  echo "run the following command to redirect port 80 traffic the http proxy:"
  echo -e "\tiptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to 12345"
  echo
fi

if [ ! -z "$https_proxy" ] ; then
  ip=$(parse_ip "$https_proxy")
  port=$(parse_port "$https_proxy")
  (cat <<EOF
redsocks {
  type = http-connect;
  ip = $ip;
  port = $port;
  local_ip = 127.0.0.1;
  local_port = 12346;
  listenq = 512;
  on_proxy_fail = forward_http_err;
}
EOF
) >> /tmp/redsocks.conf
  echo
  echo "run the following command to redirect port 443 traffic the https proxy:"
  echo -e "\tiptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to 12346"
  echo
fi

exec /usr/bin/redsocks -c /tmp/redsocks.conf
