# Terraform for IBM provide (REQUIRED)
terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

# Configure the IBM Provider (REQUIRED)
provider "ibm" {
  region = "us-south"
}

# Create code engine project
data "ibm_resource_group" "group" {
  name = "Terraform-RG"
}

resource "ibm_code_engine_project" "code_engine_project_instance" {
  name              = "terraform-test-7"
  resource_group_id = data.ibm_resource_group.group.id
}

resource "ibm_code_engine_secret" "code_engine_secret_instance" {
  project_id = ibm_code_engine_project.code_engine_project_instance.project_id
  name = "my-secret"
  format = "generic"

  data = {
        DATABASE_PASSWORD = "mydatabasepassword"
        elastic_password  = "myelasticpassword"
        kibana_password   = var.kibana_password
  }
}

resource "ibm_code_engine_app" "code_engine_app_instance" {
  project_id      = ibm_code_engine_project.code_engine_project_instance.project_id
  name            = "terraform-app"
  image_reference = "icr.io/codeengine/helloworld"

  run_env_variables {
    type  = "literal"
    name  = "ENVIRONMENT"
    value = "Dev"
  }
  
  run_env_variables {
    type  = "literal"
    name  = "USERNAME"
    value = "user-2"
  }

  run_env_variables {
    type  = "literal"
    name  = "sql_server_ip"
    value = "100.100.100.100"
  }

  run_env_variables {
    type  = "literal"
    name  = "DISABLED_COS"
    value = "True"
  }

  run_env_variables {
    type  = "secret_full_reference"
    reference = "my-secret" 
  }
}


output "terraform_app_name"{
  value = ibm_code_engine_project.code_engine_project_instance.name
}

output "terraform_app_state"{
  value = ibm_code_engine_project.code_engine_project_instance.status
}
