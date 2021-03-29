#!/usr/bin/env python
#
import os
from time import sleep

from terraform import Main as terraform
from ansible import Main as ansible
from mongodb.ans_mongo_hosts import Main as ans_hosts
from parse_tf_aws_instances import run as read_hosts_tf
from parse_tf_ssh_key import run as read_ssh_tf
from mongodb.mongodb_keys import Main as create_keys

######################### DELETE
# revisit

from ed_helper_publisher.loggerly import get_logger
from ed_helper_publisher.utilities import print_json
from ed_helper_publisher.shellouts import execute5 as execute
######################### DELETE

class Main(object):

    def __init__(self,**kwargs):

        self.classname = 'Ec2MongoDb'
        self.logger = get_logger(self.classname)[0]
        self.logger.debug("Instantiating %s" % self.classname)

        self.cwd = os.getcwd()
        self.terraform_dir = os.path.join(self.cwd,"devtools","terraform","mongodb")
        self.ansible_dir = os.path.join(self.cwd,"devtools","ansible","mongodb")
        self.ans_retries = 30
        self.ans_sleep = 5

    def _create_ec2_instances(self):

        # create ec2 instances
        os.chdir(self.terraform_dir)
        _terraform = terraform()

        return _terraform.create()

    def _create_encrypt_files(self):

        files_dir = os.path.join(self.ansible_dir,"roles","init_replica_nodes","files")
        _create_keys = create_keys(files_dir=files_dir)
        _create_keys.create()

    def _get_ssh_key_frm_tfstate(self):

        os.chdir(self.terraform_dir)

        return read_ssh_tf()["private_key"]

    def _create_ans_ssh_key(self):

        os.chdir(self.ansible_dir)

        filepath = os.path.join(self.ansible_dir,"ssh_key.pem")

        private_key = self._get_ssh_key_frm_tfstate()

        _lines = private_key.split('\n')
    
        with open(filepath,"wb") as wfile:
            for _line in _lines:
                wfile.write(_line)
                wfile.write("\n")

        os.system("chmod 400 {}".format(filepath))

    def _create_ans_hosts(self):

        hosts_info = self._get_hosts_frm_tfstate()

        os.chdir(self.ansible_dir)
        os.system("rm -rf hosts")
        os.system("rm -rf ssh_key.pem")

        public_ips = []
        private_ips = []

        for host_info in hosts_info:
            private_ips.append(host_info["private_ip"])
            if not host_info.get("public_ip"): continue
            public_ips.append(host_info["public_ip"])

        inputargs = {"private_ips":private_ips}
        inputargs["config_network"] = private_ips[0]
        inputargs["private_main"] = private_ips[0]
        inputargs["config_file_path"] = os.path.join(self.ansible_dir,"hosts")

        inputargs["config_ips"] = private_ips

        # DELETE BELOW
        # revisit
        inputargs["config_ips"] = public_ips
        inputargs["config_network"] = public_ips[0]

        _ans_hosts = ans_hosts(**inputargs)
        _ans_hosts.create()
    
    def _get_hosts_frm_tfstate(self):

        os.chdir(self.terraform_dir)
        hosts_info = read_hosts_tf()

        return hosts_info

    def _ans_test_ssh(self):

        os.chdir(self.ansible_dir)

        exec_ymls = [ "entry_point/05-test-ssh.yml" ]

        _ansible = ansible(exec_ymls=exec_ymls)

        for retry in range(self.ans_retries):

            self.logger.debug("Checking ssh retry {}".format(retry))

            results = _ansible.create(exit_error=False)

            if results.get("status"): return results

            sleep(self.ans_sleep)

        results = _ansible.create(exit_error=True)

    def _ans_to_mongodb(self):

        os.chdir(self.ansible_dir)

        exec_ymls = [ "entry_point/10-install-python.yml",
                      "entry_point/20-mongo-setup.yml",
                      "entry_point/30-mongo-init-replica.yml",
                      "entry_point/40-mongo-add-slave-replica.yml" ]

        _ansible = ansible(exec_ymls=exec_ymls)
        return _ansible.create()

    def destroy(self):

        os.chdir(self.terraform_dir)
        _terraform = terraform()

        return _terraform.destroy()

    def create(self):

        # UNDELETE
        # revisit
        self._create_ec2_instances()
        self._create_ans_hosts()
        self._create_encrypt_files()
        self._create_ans_ssh_key()
        self._ans_test_ssh()
        sleep(30)
        self._ans_to_mongodb()

        return 

def usage():

    print """

environmental variables:

    ANSIBLE_DIR (optional) - we use the ansible directory relative to execution directory

       """
    exit(4)

if __name__ == '__main__':

    main = Main()
    main.create()
