#!/bin/bash

function ConnectToServer() {
  local ip
  ip=$1
  SendChat "connecting to server $ip..."
  SendChat "echo \"$username\" | nc -u -w 1 $ip 4204"
  echo "$username" | nc -u -w 1 $ip 4204
  SendChat "connected."
}

function TestNetDependency() {
  local ret
  command -v nc >/dev/null 2>&1 || {
    IsNcSupport=0 # nc not installed
    return
  }
  nc -w 1 -ul 4204
  ret=$(echo $?)
  echo "ret=$ret"
  if [ "$ret" == "0" ]
  then
    IsNcSupport=1
  fi
  IsNcSupport=0 # nc args not supported
}

# threaded
function NetTick() {
  while [ $IsNcSupport -eq 1 ]
  do
    # server:
    # echo "1" | nc -u -w 1 localhost 4204

    # client:
    nc -W 1 -ul 4204 >> .chidraqul_tmp/client.recv
  done
}

# called in main thread tick function
function ReadNetworkTick() {
  if [ ! -f .chidraqul_tmp/client.recv ]
  then
    return
  fi
  # NetRead=$(cat .chidraqul_tmp/client.recv)
  NetRead=$(grep "." .chidraqul_tmp/client.recv | tail -1)
}

