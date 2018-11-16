#!/bin/bash
#
# Deploy our world-class make-me-rich-quick-scheme app!
echo "= Deploying microservices ="
kubectl -n jaeger apply -f - <<EOF
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    inject-jaeger-agent: "true"
  labels:
    app: time-app
    component: router
  name: router
spec:
  progressDeadlineSeconds: 60
  replicas: 1
  revisionHistoryLimit: 0
  selector:
    matchLabels:
      app: time-app
      component: router
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: time-app
        component: router
    spec:
      containers:
      - image: time-app
        imagePullPolicy: Never
        name: router
        command: ['python', '/app/router.py']
        resources:
          limits:
            cpu: 50m
            memory: 50Mi
          requests:
            cpu: 50m
            memory: 50Mi
        livenessProbe:
          httpGet:
            path: /healthz/live
            scheme: HTTP
            port: 80
        readinessProbe:
          httpGet:
            path: /healthz/ready
            scheme: HTTP
            port: 80
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        - name: metrics
          containerPort: 8080
          protocol: TCP
      terminationGracePeriodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "8080"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
  labels:
    app: time-app
    component: router
  name: router
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: time-app
    component: router
  type: NodePort
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    inject-jaeger-agent: "true"
  labels:
    app: time-app
    component: year
  name: year
spec:
  progressDeadlineSeconds: 60
  replicas: 2
  revisionHistoryLimit: 0
  selector:
    matchLabels:
      app: time-app
      component: year
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: time-app
        component: year
    spec:
      containers:
      - image: time-app
        imagePullPolicy: Never
        name: year
        command: ['python', '/app/year.py']
        resources:
          limits:
            cpu: 50m
            memory: 50Mi
          requests:
            cpu: 50m
            memory: 50Mi
        livenessProbe:
          httpGet:
            path: /healthz/live
            scheme: HTTP
            port: 80
        readinessProbe:
          httpGet:
            path: /healthz/ready
            scheme: HTTP
            port: 80
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        - name: metrics
          containerPort: 8080
          protocol: TCP
      terminationGracePeriodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "8080"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
  labels:
    app: time-app
    component: year
  name: year
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
  selector:
    app: time-app
    component: year
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    inject-jaeger-agent: "true"
  labels:
    app: time-app
    component: month
  name: month
spec:
  progressDeadlineSeconds: 60
  replicas: 2
  revisionHistoryLimit: 0
  selector:
    matchLabels:
      app: time-app
      component: month
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: time-app
        component: month
    spec:
      containers:
      - image: time-app
        imagePullPolicy: Never
        name: month
        command: ['python', '/app/month.py']
        resources:
          limits:
            cpu: 50m
            memory: 50Mi
          requests:
            cpu: 50m
            memory: 50Mi
        livenessProbe:
          httpGet:
            path: /healthz/live
            scheme: HTTP
            port: 80
        readinessProbe:
          httpGet:
            path: /healthz/ready
            scheme: HTTP
            port: 80
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        - name: metrics
          containerPort: 8080
          protocol: TCP
      terminationGracePeriodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "8080"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
  labels:
    app: time-app
    component: month
  name: month
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
  selector:
    app: time-app
    component: month
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    inject-jaeger-agent: "true"
  labels:
    app: time-app
    component: day
  name: day
spec:
  progressDeadlineSeconds: 60
  replicas: 2
  revisionHistoryLimit: 0
  selector:
    matchLabels:
      app: time-app
      component: day
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: time-app
        component: day
    spec:
      containers:
      - image: time-app
        imagePullPolicy: Never
        name: day
        command: ['python', '/app/day.py']
        resources:
          limits:
            cpu: 50m
            memory: 50Mi
          requests:
            cpu: 50m
            memory: 50Mi
        livenessProbe:
          httpGet:
            path: /healthz/live
            scheme: HTTP
            port: 80
        readinessProbe:
          httpGet:
            path: /healthz/ready
            scheme: HTTP
            port: 80
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        - name: metrics
          containerPort: 8080
          protocol: TCP
      terminationGracePeriodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "8080"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
  labels:
    app: time-app
    component: day
  name: day
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
  selector:
    app: time-app
    component: day
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    inject-jaeger-agent: "true"
  labels:
    app: time-app
    component: hour
  name: hour
spec:
  progressDeadlineSeconds: 60
  replicas: 2
  revisionHistoryLimit: 0
  selector:
    matchLabels:
      app: time-app
      component: hour
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: time-app
        component: hour
    spec:
      containers:
      - image: time-app
        imagePullPolicy: Never
        name: hour
        command: ['python', '/app/hour.py']
        resources:
          limits:
            cpu: 50m
            memory: 50Mi
          requests:
            cpu: 50m
            memory: 50Mi
        livenessProbe:
          httpGet:
            path: /healthz/live
            scheme: HTTP
            port: 80
        readinessProbe:
          httpGet:
            path: /healthz/ready
            scheme: HTTP
            port: 80
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        - name: metrics
          containerPort: 8080
          protocol: TCP
      terminationGracePeriodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "8080"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
  labels:
    app: time-app
    component: hour
  name: hour
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
  selector:
    app: time-app
    component: hour
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    inject-jaeger-agent: "true"
  labels:
    app: time-app
    component: minute
  name: minute
spec:
  progressDeadlineSeconds: 60
  replicas: 2
  revisionHistoryLimit: 0
  selector:
    matchLabels:
      app: time-app
      component: minute
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: time-app
        component: minute
    spec:
      containers:
      - image: time-app
        imagePullPolicy: Never
        name: minute
        command: ['python', '/app/minute.py']
        resources:
          limits:
            cpu: 50m
            memory: 50Mi
          requests:
            cpu: 50m
            memory: 50Mi
        livenessProbe:
          httpGet:
            path: /healthz/live
            scheme: HTTP
            port: 80
        readinessProbe:
          httpGet:
            path: /healthz/ready
            scheme: HTTP
            port: 80
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        - name: metrics
          containerPort: 8080
          protocol: TCP
      terminationGracePeriodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "8080"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
  labels:
    app: time-app
    component: minute
  name: minute
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
  selector:
    app: time-app
    component: minute
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    inject-jaeger-agent: "true"
  labels:
    app: time-app
    component: second
  name: second
spec:
  progressDeadlineSeconds: 60
  replicas: 2
  revisionHistoryLimit: 0
  selector:
    matchLabels:
      app: time-app
      component: second
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: time-app
        component: second
    spec:
      containers:
      - image: time-app
        imagePullPolicy: Never
        name: second
        command: ['python', '/app/second.py']
        resources:
          limits:
            cpu: 50m
            memory: 50Mi
          requests:
            cpu: 50m
            memory: 50Mi
        livenessProbe:
          httpGet:
            path: /healthz/live
            scheme: HTTP
            port: 80
        readinessProbe:
          httpGet:
            path: /healthz/ready
            scheme: HTTP
            port: 80
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        - name: metrics
          containerPort: 8080
          protocol: TCP
      terminationGracePeriodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "8080"
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
  labels:
    app: time-app
    component: second
  name: second
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
  selector:
    app: time-app
    component: second
EOF
