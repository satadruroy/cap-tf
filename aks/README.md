1. Checkout the `e2e-cap-deploy` branch and create a terraform.tfvars file in the sub-directory for the cloud platform you're targetting (aks|eks|gke) with the following information:
    -  location
    -  az_resource_group 
    -  ssh_public_key (SSH key file to SSH into worker nodes)
    -  agent_admin(SSH user name)
    -  client_id (Azure Service Principal client id - must be created with `az ad sp create-for-rbac`, cannot be created via portal)  
    -  client_secret ( Azure SP client secret)
    - cluster_labels (any cluster labels, an optional map of key value pairs)
    - scf_domain (your domain where CAP will be deployed)
    - azure_dns_json set this to the filesystem location of  a file azure-dns.json that contains the following info:
    {
        "tenantId": "xxxxxxxxxx",
        "subscriptionId": "xxxxxxx",
        "resourceGroup": "xxxxxx",
        "aadClientId": "xxxxx",
        "aadClientSecret": "xxxxx"
    }
Note that the adClientId/Secret above are the same as the client_id/client_secret above for the Azure SP which should have sufficient rights to create DNS records in the resource group hosting the DNS zone. For security purposes, ensure that .gitignore has an entry for this file or its naming convention.

2. Within that directory, run `terraform init`

3. Upon completion, run `terraform plan -out <PLAN-path>`

4. `terraform apply plan <PLAN-path>`

5. A kubeconfig named aksk8scfg is generated in the same directory TF is run from. Set or export KUBECONFIG as an environment variable to point to this file.

6. Check that the default namespace to make sure `external-dns` and Ingress Controller are deployed via `kubectl`

7. Deploy UAA per the CAP documentation via the helm chart.

8. If you are using loadbalanced services, set/export NS to what your uaa name space is and DOMAIN to the domain you are using. Once the services are up, go up one directory to the root `cap-tf` directory and run `./ext-dns-uaa-svc-annotate.sh` to let `external-dns` generate the DNS entries for the `uaa-uaa-public` service in the Azure DNS zone. If you are using Ingress, you don't need to do anything. 

9. Grab the CA_CERT from the secret and deploy SCF per the CAP documentation.

10. Set/export NS to the SCF namespace now, which was previously set to the UAA namespace. Similar to the previous annotation command to set the UAA DNS, run `../ext-dns-cf-svc-annotate.sh` to create the DNS entries for the SCF load balanced services in the Azure DNS zone.
  
