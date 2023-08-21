terraform {  
    required_providers {  
        harness = {  
            source = "harness/harness"  
            version = "0.24.2"  
        }
        kubectl = {
            source  = "gavinbunney/kubectl"
            version = ">= 1.14.0"
        }
    }
}  

provider "harness" {  
    endpoint   = "https://app.harness.io/gateway"  
    account_id = var.account_id  
    platform_api_key = var.harness_api_token 
}

provider "kubectl" {
  load_config_file = true
}


