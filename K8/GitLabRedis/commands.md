#will be converted through ansible 
1) helm repo add gitlab https://charts.gitlab.io/
2) helm install gitlab gitlab/gitlab \
  --set global.hosts.domain=127.0.0.1 \
  --set certmanager-issuer.email=asrithabodepudi@gmail.com
3) kubectl get ingress -lrelease=gitlab
4) 