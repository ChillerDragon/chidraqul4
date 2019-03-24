#!/bin/bash

mkdir -p .chidraqul_tmp
var=0
client_ips=()
client_usernames=()

function Main() {
  # remove cached client list
  printf "" > .chidraqul_tmp/server_clients.txt
  ListenConnections &
  while [ true ]
  do
    ReadClientList # fetch clients collected in listen thread
    OnTick
  done
}

function OnTick() {
  local i
  sleep 1
  var=$((var + 1))
  echo "ontick"
  for i in "${!client_ips[@]}"; do
    PlayerTick $i $var
  done
}

# args: playerID, serverData
function PlayerTick() {
  local player_id
  local server_data
  local player_name
  local player_ip
  server_data=$2
  player_id=$1
  player_ip=${client_ips[$player_id]}
  player_name=${client_usernames[$player_id]}
  printf "send var=%s to [%s]\t%s\n" "$server_data" "$player_ip" "$player_name"
  echo "$server_data" | nc -u -w 1 $player_ip 4204
}

function ReadClientList() {
  local username
  local ip
  client_ips=()
  client_usernames=()
  while read -r line; do
    ip=$(echo $line | cut -d ";" -f 1)
    username=$(echo $line | cut -d ";" -f 2)
    client_ips+=($ip)
    client_usernames+=($username)
  done < .chidraqul_tmp/server_clients.txt
}

# listen thread
function ListenConnections() {
  while [ true ]
  do
    ListenTick
    PrintClientList
  done
}

function PrintClientList() {
  echo "client list:"
  printf "" > .chidraqul_tmp/server_clients.txt
  for i in "${!client_ips[@]}"; do
    printf "client [%s]\t%s\n" "${client_ips[$i]}" "${client_usernames[$i]}"
    echo "${client_ips[$i]};${client_usernames[$i]}" >> .chidraqul_tmp/server_clients.txt
  done
}

function ListenTick () {
  local client_ip
  local client_port
  local client_data
  # nc -W 1 -ul 4204 -v |& tee | head -n 2 | tail -n 1 | cut -d " " -f 3
  nc -W 1 -ul 4204 -v |& tee > .chidraqul_tmp/server_lst.recv
  client_ip=$(cat .chidraqul_tmp/server_lst.recv | head -n 2 | tail -n 1 | cut -d " " -f 3)
  client_port=$(cat .chidraqul_tmp/server_lst.recv | head -n 2 | tail -n 1 | cut -d " " -f 4)
  client_data=$(cat .chidraqul_tmp/server_lst.recv | tail -n 1)
  if [ "$(IsKnownIP $client_ip)" == "1" ]
  then
    echo "got data from connected player"
  else
    echo "player joined the game"
    client_ips+=("$client_ip")
    client_usernames+=("$client_data")
  fi
  echo "got connection from"
  echo "ip: $client_ip"
  echo "port: $client_port"
  echo "data: $client_data"
}

function IsKnownIP() {
  local i
  local ip
  ip=$1
  for i in "${!client_ips[@]}"; do
    if [ "$ip" == "${client_ips[$i]}" ]
    then
      # echo "'$ip' is in list"
      echo "1";
      return
    fi
  done
  # echo "'$ip' is not in list"
  echo "0";
}

Main
