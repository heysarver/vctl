#!/bin/bash

action=$1
shift
parameters=("$@")

case "$action" in
  create)
    echo "Creating the vcluster..."
    ./scripts/create.sh $parameters
    ;;
  delete)
    echo "Deleting the vcluster..."
    ./scripts/delete.sh $parameters
    ;;
  *)
    echo "Command not found"
    exit 1
    ;;
esac
