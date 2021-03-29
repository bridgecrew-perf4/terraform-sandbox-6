#!/usr/bin/env python

import os

######################### DELETE
from ed_helper_publisher.shellouts import mkdir
from ed_helper_publisher.loggerly import get_logger
from ed_helper_publisher.shellouts import execute5 as execute
######################### DELETE

class Main(object):

    def __init__(self,**kwargs):

        self.app_name = 'terraform'
        self.classname = '{}Wrapper'.format(self.app_name)
        self.logger = get_logger(self.classname)[0]
        self.logger.debug("Instantiating %s" % self.classname)

        self.cwd = os.getcwd()

    def _exec_local_destroy(self):

        os.chdir(self.cwd)

        cmds = [ "chmod -R 777 .terraform" ]
        cmds.append("terraform init")

        for cmd in cmds:
            execute(cmd,exit_error=False)

        cmd = "terraform destroy -auto-approve"
        results = execute(cmd,exit_error=True)

        return results

    def _exec_local_create(self):

        '''
        executes terraform locally
        '''

        os.chdir(self.cwd)

        cmds = [ "terraform init" ]
        cmds.append("chmod -R 777 .terraform")
        
        for cmd in cmds: 
            execute(cmd,exit_error=False)

        cmds = [ "terraform plan" ]
        cmds.append("terraform apply -auto-approve")

        for cmd in cmds: 
            results = execute(cmd,exit_error=True)

        return results

    def destroy(self):

        os.chdir(self.cwd)

        return self._exec_local_destroy()

    def create(self):

        os.chdir(self.cwd)

        results = self._exec_local_create()

        try:
            if results.get("status") is False: 
                self.logger.warn("execution is failed")
                exit(19)
        except:
            self.logger.debug("execution is successful")

        return results

def usage():

    print """
script + environmental variables

or

script + json_input (as argument)

environmental variables:

    basic:
        METHOD - create/destroy
        TERRAFORM_DIR (optional) - we use the terraform directory relative to execution directory
       """
    exit(4)

if __name__ == '__main__':

    main = Main()
    method = os.environ.get("METHOD")

    if method == "create":
        main.create()

    elif method == "destroy":
        main.destroy()

    else:
        usage()
        print 'method "{}" not supported!'.format(method)
        exit(4)
