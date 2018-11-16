#!/bin/bash
#
# This deploys jaeger-all-in-one inside the cluster.
echo "= Create Jaeger Namespace ="
kubectl create namespace jaeger
echo "= Deploy Jaeger components ="
kubectl -n jaeger apply -f - <<EOF
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: jaeger-operator
rules:
- apiGroups:
  - io.jaegertracing
  resources:
  - "*"
  verbs:
  - "*"
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - endpoints
  - persistentvolumeclaims
  - events
  - configmaps
  - secrets
  verbs:
  - "*"
- apiGroups:
  - apps
  resources:
  - deployments
  - daemonsets
  - replicasets
  - statefulsets
  verbs:
  - "*"
- apiGroups:
  - extensions
  resources:
  - ingresses
  verbs:
  - "*"
- apiGroups:
  - batch
  resources:
  - jobs
  verbs:
  - "*"
---

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: default-account-jaeger-operator
subjects:
- kind: ServiceAccount
  name: default
  namespace: jaeger
roleRef:
  kind: ClusterRole
  name: jaeger-operator
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: jaegers.io.jaegertracing
spec:
  group: io.jaegertracing
  names:
    kind: Jaeger
    listKind: JaegerList
    plural: jaegers
    singular: jaeger
  scope: Namespaced
  version: v1alpha1
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger-operator
spec:
  replicas: 1
  selector:
    matchLabels:
      name: jaeger-operator
  template:
    metadata:
      labels:
        name: jaeger-operator
    spec:
      containers:
        - name: jaeger-operator
          image: jaegertracing/jaeger-operator:1.8.0
          ports:
          - containerPort: 60000
            name: metrics
          args: ["start"]
          imagePullPolicy: Always
          env:
            - name: WATCH_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: OPERATOR_NAME
              value: "jaeger-operator"
---
apiVersion: io.jaegertracing/v1alpha1
kind: Jaeger
metadata:
  name: simplest
spec:
  ingress:
    enabled: true
EOF
