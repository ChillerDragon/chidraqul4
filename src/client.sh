#!/bin/bash

function ConnectToServer() {
  local ip
  ip=$1
  SendChat "connecting to server $ip..."
  SendChat "echo \"$username\" | nc -u -w 1 $ip 4204"
  echo "$username" | nc -u -w 1 $ip 4204
  SendChat "connected."
}

# threaded
function NetTick() {
  while [ true ]
  do
    # server:
    # echo "1" | nc -u -w 1 localhost 4204

    # client:
    nc -W 1 -ul 4204 >> .chidraqul_tmp/client.recv
  done
}

# called in main thread tick function
function ReadNetworkTick() {
  # NetRead=$(cat .chidraqul_tmp/client.recv)
  NetRead=$(grep "." .chidraqul_tmp/client.recv | tail -1)
}

