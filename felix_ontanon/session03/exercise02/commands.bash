#!/bin/bash

export KUBECONFIG=~/.kube/sandbox.conf
export MY_SANDBOX_IP=35.173.186.247

# Straight forward :)

kubectl create ns se03ex02
kubectl --namespace=se03ex02 create -f cm.yaml
kubectl --namespace=se03ex02 create -f secret.yaml
kubectl --namespace=se03ex02 create -f mariadb-deployment.yaml
kubectl --namespace=se03ex02 create -f mariadb-svc.yaml
kubectl --namespace=se03ex02 create -f wordpress-deployment.yaml
kubectl --namespace=se03ex02 create -f wordpress-svc.yaml
kubectl --namespace=se03ex02 create -f ingress.yaml

# Let go with the real thing !

# Installing calico as Kubernetes Network Plugin.
# Further reference https://docs.bitnami.com/kubernetes/how-to/secure-your-kubernetes-application-with-networkpolicies/
kubectl apply -f https://docs.projectcalico.org/v2.4/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

# Install deny-all and mariadb-wordpress-allow network policies
kubectl --namespace=se03ex02 create -f netpolicy.yaml  --validate=false #to ignore yaml validation errors as it complains.

# Let' validate it works by creating a new testing pod
kubectl --namespace=se03ex02 create -f resources/busybox.yaml

# Testing access through busybox to wordpress (Worked !)
kubectl --namespace=se03ex02 exec -it busybox -- telnet wordpress 80
# GET / 
# <!DOCTYPE html>
# <html lang="en-US" class="no-js no-svg">
# <head>
# <meta charset="UTF-8">
# <meta name="viewport" content="width=device-width, initial-scale=1">
# <link rel="profile" href="http://gmpg.org/xfn/11">

# <script>(function(html){html.className = html.className.replace(/\bno-js\b/,'js')})(document.documentElement);</script>
# <title>Session03 Exercise02 &#8211; Just another WordPress site</title>
# <link rel='dns-prefetch' href='//fonts.googleapis.com' />
# <link rel='dns-prefetch' href='//s.w.org' />

# Testing access through busybox to wordpress (should be forbidden by network-policy but does not works :/)
kubectl --namespace=se03ex02 exec -it busybox -- telnet mariadb 3306
# Y
# 5.5.5-10.1.32-MariaDB
#                      Ja+N'wD-!?�Q5Pty#>MJiR>mysql_native_passwords