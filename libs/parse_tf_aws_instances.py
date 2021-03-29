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
    
    results = []
    
    for resource in data["resources"]:
    
        if resource.get("type") != "aws_instance": continue
    
        for instance in resource["instances"]:
            _results = {"resource_type":"aws_instance"}
            _results["_id"] = instance["attributes"]["id"]
            _results["ami"] = instance["attributes"]["ami"]
            _results["arn"] = instance["attributes"]["arn"]
            
            _results["private_dns"] = instance["attributes"]["private_dns"]
            _results["private_ip"] = instance["attributes"]["private_ip"]
            
            if instance["attributes"].get("public_dns"):
                _results["public_dns"] = resource["instances"][0]["attributes"]["public_dns"]
            
            if instance["attributes"].get("public_ip"):
                _results["public_ip"] = instance["attributes"]["public_ip"]
    
            results.append(_results)

        return results
    
if __name__ == '__main__':
    run()
