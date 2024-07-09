#!/bin/bash

port=8080
profiles=prd
url="http://localhost:$port"
dir=/home/ubuntu/jenkins-sample
jarFile=jenkins-sample.jar

echo "***********SERVICE DOWN START***********"

kill -15 $(ps -ef | grep java | grep port=$port | awk '{print $2}')

sleep 5

for cnt in {1..10}
  do
    echo "***********SERVICE DOWN CHECKING... (${cnt}/10)***********";
    STATUS=$(ps -ef | grep java | grep port=$port | awk '{print $2}')
    if [ -z "$STATUS" ]
    then
      echo "***********SERVICE DOWN OK***********"
      break;
    else
      sleep 5
      continue
    fi
  done

if [ ${cnt} -eq 10 ]
then
    echo "***********SERVICE DOWN FAIL***********"
    exit 1
fi

echo """
"""
echo "***********SERVICE UP START***********"
set +x
nohup java -jar "-Dserver.port=$port" "-Dspring.profiles.active=$profiles" $dir/$jarFile >> $dir/logs/nohup.log 2>&1 &

sleep 10

for cnt in {1..10}
  do
    echo "***********SERVICE UP CHECKING... (${cnt}/10)***********";
    STATUS=$(curl -o /dev/null -w "%{http_code}" "${url}")
    if [ "$STATUS" -eq 200 ] || [ "$STATUS" -eq 401 ]
    then
      echo "***********SERVICE UP OK***********"
      break;
    else
      sleep 5
      continue
    fi
  done

if [ "${cnt}" -eq 10 ]
then
    echo "***********SERVICE UP FAIL***********"
    exit 1
fi
