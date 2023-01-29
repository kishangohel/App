#!/bin/bash

ENVIRONMENTS="development staging production"

if [[ "$1" != "" ]]; then
    VERIFI_ENVIRONMENT="$1";
else
    VERIFI_ENVIRONMENT=development;
fi

if [[ " $ENVIRONMENTS " =~ " $VERIFI_ENVIRONMENT " ]]; then
  local_ip=$(ifconfig en0 inet | grep inet | cut -d " " -f 2)
  run_command="flutter run --target=lib/main_$VERIFI_ENVIRONMENT.dart --flavor $VERIFI_ENVIRONMENT --dart-define=VERIFI_DEV_LOCAL_IP=$local_ip"
  echo $run_command
  eval "TERM=xterm $run_command"
else
  echo "Unknown environment: $VERIFI_ENVIRONMENT, please choose one of: $ENVIRONMENTS";
fi
