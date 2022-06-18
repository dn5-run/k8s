kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

read -p "Press [Enter] key to continue..."

# Apply secret values
kubectl apply -f setup/.secret.yml

# Install metallb (https://github.com/metallb/metallb)
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
## Configure metallb
kubectl apply -f setup/metallb/metallb.yml

# Install metrics server (https://github.com/kubernetes-sigs/metrics-server)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Install kubernetes dashboard (https://github.com/kubernetes/dashboard)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml
kubectl apply -f setup/dashboard/admin.yml

# Install argocd (https://argoproj.github.io/argocd/)
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

read -p "Would you like to set it up for cloudflare access? (y/N): " yn
case "$yn" in [yY]*) ;; *) exit ;; esac

kubectl apply -f setup/nginx.yml
kubectl apply -f setup/argo-tunnel.yml