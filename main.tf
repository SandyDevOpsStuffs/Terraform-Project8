provider "aws" {
  region = "ap-south-1"  # Change to your desired region
}

resource "aws_instance" "k3s-node" {
  ami           = "ami-0287a05f0ef0e9d9a"  # Use a valid AMI ID
  instance_type = "t3.medium"            # Choose an appropriate instance type
  key_name      = "mumbai"               # Provide your key pair name
  tags = {
    Name = "SDM-K3s-Helm-Beats"
  }
  user_data = <<-EOF
    #!/bin/bash
    curl -sfL https://get.k3s.io | sh -
    EOF
}

resource "null_resource" "add_elastic_repo" {
  provisioner "local-exec" {
    command = "helm repo add elastic https://helm.elastic.co"
  }
}

provider "helm" {
  kubernetes {
    config_path = "/home/ubuntu/Terraform-Projects/Project8/k3s.yaml"
    
  }
}

resource "helm_release" "filebeat" {
  chart     = "elastic/filebeat"
  name      = "filebeat"
  version   = "7.17.3"  # Use the desired version

  depends_on = [null_resource.add_elastic_repo]
  
  wait = false
  values = [    "${file("values_filebeat.yaml")}"  ]
  force_update = true
  atomic = true
  cleanup_on_fail = true
}


resource "helm_release" "metricbeat" {
  chart     = "elastic/metricbeat"
  name      = "metricbeat"
  version   = "7.17.3"  # Use the desired version

  depends_on = [null_resource.add_elastic_repo]
  
  wait = false
  values = [    "${file("values_metricbeat.yaml")}"  ]
  force_update = true
  atomic = true
  cleanup_on_fail = true
  
}


