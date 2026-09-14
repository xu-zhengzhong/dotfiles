# Helpers for running commands with or without the local network proxy.

PROXY_HOST=127.0.0.1
PROXY_PORT=7897

proxy() {
	HTTP_PROXY="http://${PROXY_HOST}:${PROXY_PORT}" \
	HTTPS_PROXY="http://${PROXY_HOST}:${PROXY_PORT}" \
	http_proxy="http://${PROXY_HOST}:${PROXY_PORT}" \
	https_proxy="http://${PROXY_HOST}:${PROXY_PORT}" \
	ALL_PROXY="socks5h://${PROXY_HOST}:${PROXY_PORT}" \
	all_proxy="socks5h://${PROXY_HOST}:${PROXY_PORT}" \
	NO_PROXY="localhost,127.0.0.1,::1" \
	no_proxy="localhost,127.0.0.1,::1" \
	"$@"
}

proxyon() {
	export HTTP_PROXY="http://${PROXY_HOST}:${PROXY_PORT}"
	export HTTPS_PROXY="http://${PROXY_HOST}:${PROXY_PORT}"
	export http_proxy="$HTTP_PROXY"
	export https_proxy="$HTTPS_PROXY"

	export ALL_PROXY="socks5h://${PROXY_HOST}:${PROXY_PORT}"
	export all_proxy="$ALL_PROXY"

	export NO_PROXY="localhost,127.0.0.1,::1"
	export no_proxy="$NO_PROXY"

	echo "HTTP proxy:  $HTTP_PROXY"
	echo "SOCKS proxy: $ALL_PROXY"
}

proxyoff() {
	unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
	unset http_proxy https_proxy all_proxy no_proxy
	unset WS_PROXY WSS_PROXY ws_proxy wss_proxy

	echo "Proxy OFF"
}

proxystatus() {
	echo "HTTP_PROXY=${HTTP_PROXY:-<unset>}"
	echo "HTTPS_PROXY=${HTTPS_PROXY:-<unset>}"
	echo "ALL_PROXY=${ALL_PROXY:-<unset>}"
	echo "NO_PROXY=${NO_PROXY:-<unset>}"
	echo
	echo "http_proxy=${http_proxy:-<unset>}"
	echo "https_proxy=${https_proxy:-<unset>}"
	echo "all_proxy=${all_proxy:-<unset>}"
	echo "no_proxy=${no_proxy:-<unset>}"
}
