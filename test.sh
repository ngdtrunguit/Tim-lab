#!/bin/bash

#install Argo Rollout
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl delete -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# while
# [ $(kubectl -n argocd get pod -l app.kubernetes.io/name=argocd-server -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]; do
#  sleep 1
# done

kubectl -n argocd wait pods -l app.kubernetes.io/name=argocd-server --for condition=Ready --timeout=60s

#Get credential to argocd
argocd_pwd=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
hostname=$(kubectl get service istio-ingressgateway -n istio-ingress --output=jsonpath='{.status.loadBalancer.ingress[0].ip}')
argocd login --username admin --password ${argocd_pwd} --grpc-web --insecure --plaintext ${hostname}:80

#Install blue-green app using test-ci
argocd app create --name app-blue-green --repo https://github.com/ngdtrunguit/forCRP2.0.git --dest-server https://kubernetes.default.svc --dest-namespace application --path test-ci && argocd app sync app-blue-green
