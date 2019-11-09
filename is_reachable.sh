#!/bin/bash

## Global
_HOSTNAME=$1

## Check connection status
client_ip=$(ifconfig|grep -v 127.0.0.1|egrep -m1 'inet '| sed 's,        ,,'|cut -d' ' -f2)
[[ -z "$client_ip" ]] && echo "Client machine has no connection" && exit 1

## Warning ! Client machine should have a default gateway
if [[ ! `egrep -m1 -o  default <(route)` == "default" ]]; then 
	echo "Warning! There is no default gateway" 
	read -p "Abort procedure ?[Y][n] " op
	op=${op:0:1}
	[[ "${op,}" == "n" ]] && exit 1 
fi

## Ping the destination server by name
_ifup(){ ping -c1 "$1" > /dev/null 2>&1  && echo "$1 is up" && exit 0;}
_ifup "$_HOSTNAME"

## CHECK IP ON /etc/hosts
_ifup "$(egrep "\b$_HOSTNAME\b" /etc/hosts | cut -d' ' -f1)"

## CHECK IP USING /etc/resolv.conf
_ifup "$(host "$_HOSTNAME" | egrep -m1 "$_HOSTNAME" | cut -d' ' -f4)"

## IF $_HOSTNAME NOT FOUND ON FILES OR DNS
read -p "$_HOSTNAME not found. Insert IP manually: " _IP
_ifup "$_IP"

## IF NOTHING WORKS
echo "Destination server not reachable by ip or domain name" && exit 1
