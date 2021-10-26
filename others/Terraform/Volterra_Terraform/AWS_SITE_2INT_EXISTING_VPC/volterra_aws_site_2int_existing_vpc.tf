resource "volterra_aws_vpc_site" "aws-vpc-example" {
  name      = "dierick-aws-vpc-tf"
  namespace = "system"
  aws_region = "eu-north-1"
  
  assisted = false
  instance_type = "t3.xlarge"
  
  //AWS credentials entered in the Volterra Console
    aws_cred {
      name      = "dierick-aws-cred"
      namespace = "system"
      tenant    = ""
    }

  vpc {
    vpc_id = "vpc-ID"
  }

  ingress_egress_gw {
    aws_certified_hw = "aws-byol-multi-nic-voltmesh"
    no_forward_proxy = true
    no_global_network = true
    no_inside_static_routes = true
    no_outside_static_routes = true
    no_network_policy = true    

   
    //Availability zones and subnet options for the Volterra Node
    az_nodes {
      //AWS AZ
      aws_az_name = "eu-north-1a"
      
      //Site local outside subnet
      outside_subnet {
        existing_subnet_id = "subnet-ID1"
      }

      //Site local inside subnet
      inside_subnet {
        existing_subnet_id = "subnet-ID2"
      }

      //Workload subnet
      workload_subnet {    
        existing_subnet_id = "subnet-ID3"
      }
    }
  }
  
  //Mandatory
  logs_streaming_disabled = true
  
  //Mandatory
  no_worker_nodes = true
}