#!/bin/bash

URL="https://shellgei-web.net/post_code/"
FILE="-"
MODE="default"

help(){
	echo "Usage: $0 [OPTION] [FILE]"
	echo "With no FILE, or when FILE is -, read standard input."
	echo "  -r : print raw response"
	echo "  -f : print responce in readable format"
	echo "  -h : display this help and exit"
}

if [ $# -ge 1 ]&&[ $1 != "-" ]&&[ ${1:0:1} = "-" ];then
	case $1 in
		"-r") MODE="raw";;
		"-f") MODE="format";;
		"-h") help;exit 0;;
	esac
	shift
fi

if [ $# -ge 1 ];then
	FILE="$1"
fi

data=$(
curl \
	-sS \
	-X POST \
	-H 'Content-Type: application/json;charset=UTF-8' \
	-H 'Accept-Encoding: gzip' \
	-H 'Accept: application/json, text/plain, */*' \
	-d '{"code":'"$(cat "$FILE"|jq -Rs)"'}' \
	"$URL"|gzip -d
)

if [ "$MODE" = "raw" ];then
	echo "$data"
	exit 0
fi

case $MODE in
	"default")
		echo -n "$(jq -r .stdout <<<"$data")"
		jq -r .sysmsg <<<"$data" >&2
		;;
	"format")
		echo "[stdout]"
		jq -r .stdout <<<"$data"
		echo "[stderr]"
		jq -r .stderr <<<"$data"
		echo "[system message]"
		jq -r .sysmsg <<<"$data"
		;;
esac

num=$(($(jq '.images |length' <<<"$data")-1))
for i in $(seq 0 $num);do
	jq -r ".images[$i]" <<<"$data"|base64 -d >$i
	type=($(file -b $i))
	mv "$i" "$i.${type[0]}"
done
