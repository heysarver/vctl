#!/bin/bash

action=$1
shift
parameters=("$@")

case "$action" in
  create)
    if [ -z "${VC_DOMAIN}" ]; then
      echo "Error: VC_DOMAIN environment variable is not set.  See README.md."
      exit 1
    fi
    echo "Creating the vcluster..."
    ./scripts/create.sh $parameters
    ;;
  delete)
    echo "Are you sure you want to delete the vcluster? (y/n)"
    read confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
      echo "Deleting the vcluster..."
      ./scripts/delete.sh $parameters
    else
      echo "Aborted deleting the vcluster."
    fi
    ;;
  list)
    vcluster list $parameters
    ;;
  *)
    echo "Command not found"
    exit 1
    ;;
esac
