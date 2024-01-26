[masterNode]
masterNode ansible_host=${master_ip} ansible_user=ubuntu

[workerNodes]
%{ for ip in worker_ips ~}
workerNode${count.index} ansible_host=${ip} ansible_user=ubuntu
%{ endfor ~}

[k8Nodes:children]
masterNode
workerNodes
