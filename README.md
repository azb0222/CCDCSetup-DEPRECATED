**Todo**

- setup security groups in VPC (figure out network policies) -> then can setup ansible playbooks 
- Learn Ansible properly + install Ansible playbooks 
- configure K8 cluster via helm 
- install VPN + other shit 
- setup IAM access roles 



1) set up aws vpc resources 
2) setup wireguard via ansible 
3) create playbooks for k8 bootstrapping + running postgres 
4) create playbooks for setting up AD 
5) Vault ???? set this bs up 


steps for github actions: 
1) terraform apply 
2) take the terraform output data and create a static hosts file for ansible 
3) configure ansible with the ssh keys 
4) run ansible playboooks 


To use this:
1) create a fork of the repostory 


To create a scalable and reproducible infrastructure that several people can deploy and manage in their own AWS accounts, you'll need to prepare your Terraform and Ansible configurations to be modular and parameterized. Then, you'll use GitHub and GitHub Actions to make it easily forkable and executable. Here's how to set it up:

1. Prepare Your Infrastructure as Code:
Terraform Modules: Structure your Terraform code into modules. Each module should represent a logical part of your infrastructure (e.g., network, instances, databases). This makes it easy for others to reuse and customize the setup.

Parameterize Terraform: Use variables in Terraform to allow users to input their specific settings, such as AWS region, instance sizes, and the desired number of instances.

Ansible Roles: Organize your Ansible configurations into roles. Each role should handle a specific part of the server setup, like web servers, databases, etc.

2. Document Your Setup:
README: Provide a comprehensive README in your repository explaining what your infrastructure does, how to fork it, how to set it up, and how to run it in their own AWS account.

Comments: Comment your Terraform and Ansible code where necessary to explain what certain resources or tasks are doing.

3. GitHub Repository:
Public Repository: Host your Terraform and Ansible configurations in a public GitHub repository. Make sure there are no hard-coded secrets!

GitHub Actions Workflow: Include the GitHub Actions workflow file in the repository. Make sure it's generic enough to work across different AWS accounts and is fully parameterized.

4. Security and Secrets:
Instructions for Secrets: In your documentation, include detailed instructions on how users should set up their AWS credentials and any other required secrets in their GitHub repository as encrypted secrets.
5. Forking and Customization Instructions:
Forking Guide: Provide instructions on how to fork the repository.

Customization Steps: Guide users through customizing the Terraform variables and Ansible configurations to fit their needs.

6. Scaling Instructions:
Workflow Dispatch: Explain how they can use the workflow_dispatch event to manually trigger the scaling process in GitHub Actions, including how to specify scaling up or down.
7. Maintain and Update the Code:
Version Tags: Use tags to mark stable versions of your code.

Changelog: Keep a changelog so users can see what changes have been made in each version.

8. User Community:
Issues and Contributions: Encourage users to report issues and contribute improvements back to the original repository. This can help improve the project for everyone.
9. Licensing:
Choose an Appropriate License: Ensure your project has an open-source license so others know how they can use and modify it.
10. Example Use Cases:
Tutorials: Create a few example scenarios or tutorials for common use cases of your infrastructure.
By following these steps, you create an infrastructure project that others can easily fork, customize, and use in their own AWS accounts. This approach promotes collaboration, reuse, and sharing in the community, and it can significantly speed up similar projects across different teams or individuals. Remember, the key to successful reuse in such projects lies in good documentation, clear structure, and community engagement.



--------------------
- k8 security group for k8 nodes that only allow for traffic from the ansible controller node


#TODO: reorganize the file structure so its not complete dogshit 