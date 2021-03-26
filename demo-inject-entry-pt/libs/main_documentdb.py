#!/usr/bin/env python
#
import os
from time import sleep
from terraform import Main as terraform
from libs.parse_tf_docdb import run as read_docdb

######################### DELETE
# revisit

from ed_helper_publisher.loggerly import get_logger
from ed_helper_publisher.utilities import print_json
from ed_helper_publisher.shellouts import execute5 as execute
######################### DELETE

class Main(object):

    def __init__(self,**kwargs):

        self.classname = 'DocumentDb'
        self.logger = get_logger(self.classname)[0]
        self.logger.debug("Instantiating %s" % self.classname)

        self.cwd = os.getcwd()
        self.terraform_dir = os.path.join(self.cwd,"devtools","terraform","documentdb")

    def create(self):

        os.chdir(self.terraform_dir)
        _terraform = terraform()

        results = _terraform.create()
        endpoint = self._get_docdb_endpt_frm_tfstate()
        #self.logger.debug("documentdb results is {}".format(results))
        return endpoint

    def _get_docdb_endpt_frm_tfstate(self):

        os.chdir(self.terraform_dir)
        results = read_docdb()

        return results["endpoint"]

    def destroy(self):

        os.chdir(self.terraform_dir)
        _terraform = terraform()

        return _terraform.destroy()

if __name__ == '__main__':

    main = Main()
    main.create()
