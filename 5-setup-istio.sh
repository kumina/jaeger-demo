#!/bin/sh
#
# Set up Istio on our minikube cluster.

echo "= Setting up Istio code ="
# First, we need to download the files.
wget -nv -c https://github.com/istio/istio/releases/download/1.0.3/istio-1.0.3-linux.tar.gz
wget -nv -c https://github.com/istio/istio/releases/download/1.0.3/istio-1.0.3-linux.tar.gz.sha256
# You always check checksums as well, right?
if sha256sum -c --status "istio-1.0.3-linux.tar.gz.sha256"; then
	echo "-- Checksum matches, unpacking."
	mkdir -p istio
	tar xf istio-1.0.3-linux.tar.gz -C istio --strip-components 1
else
	echo "-- Checksum failed, aborting!"
	exit 1
fi
echo "-- Deploying Istio components"
kubectl apply -f istio/install/kubernetes/istio-demo.yaml
