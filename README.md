# Istio and Jaeger (but mostly OpenTracing)

These are the files used for my presentation "Trac(k)in and hunting with
Jaeger", which is delivered on November 15th 2018 for the Codemotion meetup at
Quanza in Amsterdam.

## Prerequisites

These scripts are tested on a Linux Mint 19.1 desktop (which is based off of
Ubuntu 18.04) and requires:

* [https://github.com/kubernetes/minikube](Minikube) (I used 1.10)
* [https://www.virtualbox.org/](VirtualBox) (Should work with other vm-drivers
  as well, but I only used VirtualBox)
* [https://kubernetes.io/docs/tasks/tools/install-kubectl/](Kubectl)
* [https://www.docker.com/](Docker)
* `wget`
* `sha256sum`

## Disclaimer

This code is very far from production ready code. It's only meant as a demo and
if you look at it closely, you will see that I intended to show a lot more and
also still have some trial-and-error stuff in here. This is, however, the actual
code that I used to run the demonstration, with all its flaws. Use at your own
risk!

## Repo

The repo consists of some numbered scripts, which helped me reproduce the build
easily. There's also a directory with the actual Python code for the app that I
demonstrated, Distributed Time.

### 1-setup.sh

This sets up the basic minikube environment. It'll increase the default specs to
6 CPUs and 12GB of RAM. It also enables some addons, which are not all in use.
To save some time, this script also downloads most (if not all) of the images
that are run within the Kubernetes "cluster" created by Minikube. I added that
step to make sure I would be able to run the demo even if I didn't have (fast)
internet.

### 2-build-time-app.sh

Before running this script, ensure your Docker environment is set to use the
Minikube Docker instead of your local one with the following command:

```
eval $(minikube --profile jaeger docker-env)
```

This sets up some environment variables that instruct your docker client to
connect to the docker daemon inside of the VirtualBox VM started by Minikube.
Run the script and it'll build the Docker image used by the Distributed Time
application.

NOTE: If you check the script, you'll see there's a `load` option as well, which
can import a saved image created with `docker save time-app > image.tar` instead
of building it. Again, that was a provision in the case I couldn't get it set up
fast enough. (Consider it an offering to the Demo Gods!)

### 3-deploy-jaeger.sh

Like it says on the wrapper, it simply created the namespace `jaeger` and
deploys the required applications inside of it. Nothing fancy. I was also
playing with the Minikube Ingress addon for this, so you'll have to modify your
local `/etc/hosts` to add a line like so:

```
echo "$(minikube ip) jaeger.mk" | sudo tee /etc/hosts
```

You can remove this entry once you're done with it. This allows you to visit
`http://jaeger.mk` with a browser to get to the Jaeger installation.

### 4-deploy-time-app.sh

This will deploy the Distribute Time application inside the `jaeger` namespace.
I did not set up an Ingress for this, I'll leave that up to you! Or you simply
check how to connect to the service by running:

```
minikube --profile jaeger service list -n jaeger
```

You'll want to use the URL that's next to the `router` container. If all is
well, you can now see the Distributed Time app in your browser! And get the
traces inside of the Jaeger instance. Notice how the liveness and readiness
checks get traces as well.

### 5-setup-istio.sh

This download the Istio 1.0.3 release and deploys it inside the namespace
`istio-system`. This also includes a dedicated Jaeger instance, which you'll
have to connect to by first creating a port forward to it with this command:

```
kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 &
```

You may want to note the PID that gets returned here, as you'll have to `kill`
it in the end to stop the forward. Another way is to simply leave out the `&` at
the end of the line and start a new terminal next to it.

Once you have the port-forward running, you can connect to that specific Jaeger
instance by visiting `http://localhost:16686` in your browser.

### 6-deploy-time-istio.sh

I'm guessing you know by now what this is supposed to do... It makes use of the
Istio Ingressgateway. To connect to it, run the command `minikube --profile
jaeger service list -n istio-system` and you'll notice a list of URLs next to
the gateway service. Just use the first one and you should be able to connect to
the Distributed Time app.

# Thanks!
