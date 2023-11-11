#!/bin/bash

# Store the first command line argument in VC_CLUSTER_NAME
parameters=("$@")
VC_CLUSTER_NAME=${parameters[0]}

# Create a new namespace using VC_CLUSTER_NAME
kubectl create ns vc-${VC_CLUSTER_NAME}

# Export environment variables
export VC_CLUSTER_NAME

# Substitute environment variables in vcluster_values.yaml and save the result to a temporary file
envsubst < ./templates/vcluster_values.yaml > /tmp/vcluster_${VC_CLUSTER_NAME}_values.yaml

# Create a new vcluster using the values from the temporary file
vcluster create "$VC_CLUSTER_NAME" \
  -n "vc-${VC_CLUSTER_NAME}" \
  -f /tmp/vcluster_${VC_CLUSTER_NAME}_values.yaml \
  -f https://raw.githubusercontent.com/loft-sh/vcluster-plugins/master/cert-manager-plugin/plugin.yaml

sleep 30

# Get the kubeconfig
kubectl get secret vc-${VC_CLUSTER_NAME} -n vc-${VC_CLUSTER_NAME} -o jsonpath='{.data.config}' | base64 -d > /tmp/kubeconfig-vc-${VC_CLUSTER_NAME}

# Patch the kubeconfig
eval "yq -i '.users.0.name = \"vc-${VC_CLUSTER_NAME}-admin\"' /tmp/kubeconfig-vc-${VC_CLUSTER_NAME}"
eval "yq -i '.clusters.0.name = \"vc-${VC_CLUSTER_NAME}\"' /tmp/kubeconfig-vc-${VC_CLUSTER_NAME}"
eval "yq -i '.contexts.0.context.cluster = \"vc-${VC_CLUSTER_NAME}\"' /tmp/kubeconfig-vc-${VC_CLUSTER_NAME}"
eval "yq -i '.contexts.0.context.user = \"vc-${VC_CLUSTER_NAME}-admin\"' /tmp/kubeconfig-vc-${VC_CLUSTER_NAME}"
eval "yq -i '.contexts.0.name = \"vc-${VC_CLUSTER_NAME}\"' /tmp/kubeconfig-vc-${VC_CLUSTER_NAME}"
eval "yq -i '.current-context = \"vc-${VC_CLUSTER_NAME}\"' /tmp/kubeconfig-vc-${VC_CLUSTER_NAME}"

#KUBECONFIG="~/.kube/config:/tmp/kubeconfig-vc-${VC_CLUSTER_NAME}" kubectl config view --flatten > /tmp/kubeconfig.new
kubecm add -f /tmp/kubeconfig-vc-${VC_CLUSTER_NAME}
