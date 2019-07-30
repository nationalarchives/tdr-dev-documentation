# Deployment

## Initial Documents

Blog on relative merits of Kubernetes v ECS (not sure how reliable it is): https://platform9.com/blog/kubernetes-vs-ecs/

Blog comparing the main orchestration offerings: https://epsagon.com/blog/aws-ecs-fargate-kubernetes-orchestration-services-comparison/

Useful deployment infrastructure diagram contained in this article about deploying to ECS using Terraform: https://dzone.com/articles/immutable-infrastructure-cicd-using-hashicorp-terr

Deploying containers to ECS using Terraform: https://medium.com/@bradford_hamilton/deploying-containers-on-amazons-ecs-using-fargate-and-terraform-part-2-2e6f6a3a957f

## Container Orchestration

### Kubernetes

Kubernetes is a properietary cloud orchestrator that provides functionality that takes care of microservices and deals with scaling, resiliency, and updates. It also let you write rules that refer to the entire system instead of having to think in terms of single microservices

### AWS ECS Fargate

AWS ECS Fargate is a managed orchestrator offered by AWS. It abstracts the underlying EC2 instances, so the only items you need to worry about are containers, the network interfaces between them, and IAM permissions. Auto-scaling is available out of the box and so is the load balancing. 

Kubernetes | AWS ECS Fargate
--- | --- 
Complex setup | More straight forward setup
High learning required | Some team experience already
Highly opinionated leading to consistency of approach | Multiple approaches possible ("roll your own")
Running Kubernetes on AWS EKS means always having a master node running. This is not free. Will also require worker nodes for which the cost is normal price for EC2 instances you launch for Worker nodes, just like the ECS offering. | Pay for memory and CPU usage independently, potential for large costs if services start executing heavy workloads
