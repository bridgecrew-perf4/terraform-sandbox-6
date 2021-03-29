#!/usr/bin/env python

import os
import json

def run():

    terraform_state_file = os.environ.get("TERRAFORM_STATE_FILE","terraform.tfstate")
    
    with open(terraform_state_file) as json_file:
        data = json.load(json_file)
    
    if not data:
        print "ERROR - there is no data from {}".format(os.path.join(os.getcwd(),terraform_state_file))
        exit(9)

    results = {}
    
    for resource in data["resources"]:
    
        if resource.get("type") != "tls_private_key": continue
    
        results["private_key"] = resource["instances"][0]["attributes"]["private_key_pem"]
        results["public_key"] = resource["instances"][0]["attributes"]["public_key_openssh"]

    return results
    
if __name__ == '__main__':
    run()
