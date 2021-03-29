#!/usr/bin/env python
#
import os
import sys

######################### DELETE
from ed_helper_publisher.loggerly import get_logger
from ed_helper_publisher.shellouts import execute5 as execute
######################### DELETE

class Main(object):

    def __init__(self,**kwargs):

        self.app_name = 'ansible'
        self.classname = '{}Wrapper'.format(self.app_name)
        self.logger = get_logger(self.classname)[0]
        self.logger.debug("Instantiating %s" % self.classname)

        self.cwd = os.getcwd()

        self.exec_ymls = kwargs["exec_ymls"]

    def _exec_local_create(self,exit_error=True):

        os.chdir(self.cwd)

        base_cmd = 'ansible-playbook -i hosts'

        for _yml in self.exec_ymls:
            cmd = "{} {}".format(base_cmd,_yml)
            results = execute(cmd,exit_error=exit_error)

        return results

    def create(self,exit_error=True):

        results = self._exec_local_create(exit_error=exit_error)
        os.chdir(self.cwd)

        return results

def usage():

    print """

environmental variables:

    ANSIBLE_DIR (optional) - we use the ansible directory relative to execution directory

       """
    exit(4)

if __name__ == '__main__':

    try:
        json_input = sys.argv[1]
    except:
        json_input = None

    main = Main()
    main.create()
