terraform {  
    required_providers {  
        harness = {  
            source = "harness/harness"  
            version = "0.24.2"  
        }
    }
}  

provider "harness" {  
    endpoint   = "https://app.harness.io/gateway"  
    account_id = ""  
    platform_api_key    = ""  
}
