#!/bin/bash

URL="https://shellgei-web.net/post_code/"
FILE="-"
MODE="default"
code=""

help(){
	echo "Usage: $0 [OPTION] [FILE|COMMAND]"
	echo "With no FILE, or when FILE is -, read standard input."
	echo "  -r : print raw response"
	echo "  -f : print responce in readable format"
	echo "  -p : read standard input and pass it to the standard input of COMMAND on the SGWeb"
	echo "  -h : display this help and exit"
}

if [ $# -ge 1 ]&&[ $1 != "-" ]&&[ ${1:0:1} = "-" ];then
	case $1 in
		"-r") MODE="raw";;
		"-f") MODE="format";;
		"-p") MODE="pipe";;
		"-h") help;exit 0;;
	esac
	shift
fi

if [ $# -ge 1 ];then
	FILE="$1"
fi

if [ "$MODE" = "pipe" ];then
	code="\"echo $(base64 -w0)|base64 -d|$1\""
else
	code="$(cat "$FILE"|jq -Rs .)"
fi

data=$(
curl \
	-sS \
	-X POST \
	-H 'Content-Type: application/json;charset=UTF-8' \
	-H 'Accept-Encoding: gzip' \
	-H 'Accept: application/json, text/plain, */*' \
	-d '{"code":'"$code"'}' \
	"$URL"|gzip -d
)

if [ "$MODE" = "raw" ];then
	echo "$data"
	exit 0
fi

sysmsg="$(jq -r .sysmsg <<<"$data")"

case "$MODE" in
	"default" | "pipe")
		jq -r .stdout <<<"$data"|head -c -1
		[ "$sysmsg" ]&&echo "$sysmsg" >&2
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
