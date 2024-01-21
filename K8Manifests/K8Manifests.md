Note: Both manifests could be installed with HELM charts as well 
## GitLab+Redis
https://blog.lwolf.org/post/how-to-easily-deploy-gitlab-on-kubernetes/


## PostgresSQL
https://www.sumologic.com/blog/kubernetes-deploy-postgres/


## Configuration: 
3 namespaces: 
gitlab (for both gitlab + redis) 
postgresql 
 

### Services: 
GitLab: web-based Git repository maanger 
Postgresql: used by GitLab as a database 
Redis: used by GitLab for caching and job queueing 