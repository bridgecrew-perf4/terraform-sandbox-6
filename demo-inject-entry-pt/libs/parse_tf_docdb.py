#!/usr/bin/env python

import os
import json

def run():

    terraform_state_file = os.environ.get("TERRAFORM_STATE_FILE","terraform.tfstate")
    
    with open(terraform_state_file) as json_file:
        data = json.load(json_file)
    
    if not data:
        print("ERROR - there is no data from {}".format(os.path.join(os.getcwd(),terraform_state_file)))
        exit(9)

    # parse tf state file
    aws_type = os.environ.get("AWS_TYPE","aws_docdb_cluster")
    resource_type = "docdb"
    provider = "aws"
    
    for resource in data["resources"]:
        for instance in resource["instances"]:
    
            if resource["type"] != aws_type: continue
    
            _results = {}

            for _key,_value in resource["instances"][0]["attributes"].iteritems():
                _results[_key] = _value
    
            _results["name"] = _results["id"]
            _results["tags"] = [ _results["name"] ]
            _results["_id"] = _results["arn"].replace(":","_").replace("/","_")
            _results["resource_type"] = resource_type
            _results["provider"] = provider
            _results["region"] = _results["arn"].split(":")[3]
    
            return _results

    return 
    
if __name__ == '__main__':
    run()
