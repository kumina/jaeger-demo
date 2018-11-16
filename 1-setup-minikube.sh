#!/bin/sh
#
# This sets up the environment in a usable way. Assumes you have at least 12GB of RAM
# available and assigns 6 cpus.
echo "= Setting up the minikube environment ="
minikube --profile jaeger start --memory 12000 --cpus 6 --extra-config=controller-manager.cluster-signing-cert-file="/var/lib/minikube/certs/ca.crt" --extra-config=controller-manager.cluster-signing-key-file="/var/lib/minikube/certs/ca.key"
echo "= Make use of the Minikube Docker environment ="
eval $(minikube --profile jaeger docker-env)
echo "= Download Docker images, if needed ="
docker pull registry.hub.docker.com/library/alpine:3.6
docker pull k8s.gcr.io/coredns:1.2.2
docker pull k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0
docker pull k8s.gcr.io/kube-proxy-amd64:v1.10.0
docker pull k8s.gcr.io/kube-scheduler-amd64:v1.10.0
docker pull k8s.gcr.io/kube-controller-manager-amd64:v1.10.0
docker pull k8s.gcr.io/kube-apiserver-amd64:v1.10.0
docker pull k8s.gcr.io/etcd-amd64:3.1.12
docker pull k8s.gcr.io/kube-addon-manager:v8.6
docker pull k8s.gcr.io/pause-amd64:3.1
docker pull k8s.gcr.io/metrics-server-amd64:v0.2.1
docker pull gcr.io/k8s-minikube/storage-provisioner:v1.8.1
docker pull k8s.gcr.io/fluentd-elasticsearch:v2.0.2
docker pull k8s.gcr.io/elasticsearch:v5.6.2
docker pull docker.elastic.co/kibana/kibana:5.6.2
docker pull python:3.6
docker pull gcr.io/google_containers/defaultbackend:1.4
docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.19.0
docker pull jaegertracing/jaeger-agent:1.8
docker pull jaegertracing/jaeger-operator:1.8.0
docker pull jaegertracing/all-in-one:1.8
docker pull docker.io/istio/citadel:1.0.3
docker pull docker.io/istio/galley:1.0.3
docker pull docker.io/istio/mixer:1.0.3
docker pull docker.io/istio/pilot:1.0.3
docker pull docker.io/istio/proxyv2:1.0.3
docker pull docker.io/istio/servicegraph:1.0.3
docker pull docker.io/istio/sidecar_injector:1.0.3
docker pull docker.io/jaegertracing/all-in-one:1.5
docker pull docker.io/prom/prometheus:v2.3.1
docker pull grafana/grafana:5.2.3
docker pull istio/citadel:1.0.3
docker pull istio/galley:1.0.3
docker pull istio/mixer:1.0.3
docker pull istio/pilot:1.0.3
docker pull istio/proxyv2:1.0.3
docker pull istio/servicegraph:1.0.3
docker pull istio/sidecar_injector:1.0.3
docker pull jaegertracing/all-in-one:1.5
docker pull prom/prometheus:v2.3.1
docker pull quay.io/coreos/hyperkube:v1.7.6_coreos.0
echo "= Enabling the services we want ="
minikube --profile jaeger addons enable coredns
minikube --profile jaeger addons enable efk
minikube --profile jaeger addons enable metrics-server
minikube --profile jaeger addons enable ingress
# Apparantly, minikube enables kube-dns regardless, so we're going to remove it.
kubectl --context jaeger -n kube-system delete deployment kube-dns || true
