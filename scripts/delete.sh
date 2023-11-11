#!/bin/bash

parameters=("$@")
VC_CLUSTER_NAME=${parameters[0]}

vcluster delete "$VC_CLUSTER_NAME" \
  -n "vc-${VC_CLUSTER_NAME}"

# finally delete the namespace
kubectl delete ns vc-$VC_CLUSTER_NAME

rm -f /tmp/kubeconfig-vc-${VC_CLUSTER_NAME}

kubecm delete vc-${VC_CLUSTER_NAME}
