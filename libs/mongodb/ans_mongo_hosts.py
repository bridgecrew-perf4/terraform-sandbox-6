#!/usr/bin/env python
#
import os
import sys

######################### DELETE
from ed_helper_publisher.loggerly import get_logger
######################### DELETE

class Main(object):

    def __init__(self,**kwargs):

        self.classname = 'MONGODB_ANSIBLE_HELPER'
        self.logger = get_logger(self.classname)[0]
        self.logger.debug("Instantiating %s" % self.classname)
        self.kwargs = kwargs

    def _set_vars(self):

        self.public_ips = self.kwargs.get("public_ips")
        self.private_ips = self.kwargs["private_ips"]
        self.config_ips = self.kwargs["config_ips"]
        self.config_network = self.kwargs["config_network"]

        self.main_private_ip = self.private_ips[0]
        if self.public_ips: self.main_public_ip = self.public_ips[0]

        if len(self.private_ips) > 1:
            self.private_secondaries = self.private_ips[1:]
        else:
            self.private_secondaries = None

        self.config_file_path = self.kwargs["config_file_path"]
        self.config_file = open(self.config_file_path,"w")

        #self.config_file_path = "{}/hosts".format(self.exec_dir)

    def _create_mongodb_keyfile(self):

        filepath = os.path.join(self.exec_dir,"roles","init_replica_nodes","files","mongodb_keyfile")

        self.write_key_to_file(key="mongodb_keyfile",
                               filepath=filepath,
                               split_char="return",
                               deserialize=True,
                               add_return=True,
                               permission=400)

    def _create_mongodb_pem(self):

        filepath = os.path.join(self.exec_dir,"roles","init_replica_nodes","files","mongodb.pem")

        self.write_key_to_file(key="mongodb_pem",
                               filepath=filepath,
                               split_char="return",
                               deserialize=True,
                               add_return=True,
                               permission=400)
        
    def _add_public(self):

        if not self.public_ips: return

        self.config_file.write('[public]')
        self.config_file.write("\n")

        for _ip in self.public_ips:
            self.config_file.write(_ip)
            self.config_file.write("\n")

        self.config_file.write("\n")

    def _add_private(self):

        self.config_file.write('[private]')
        self.config_file.write("\n")

        for _ip in self.private_ips:
            self.config_file.write(_ip)
            self.config_file.write("\n")

        self.config_file.write("\n")

    def _add_config_ips(self):

        self.config_file.write('[configuration]')
        self.config_file.write("\n")

        for _ip in self.config_ips:
            self.config_file.write(_ip)
            self.config_file.write("\n")

        self.config_file.write("\n")

    def _add_config_network(self):

        self.config_file.write('[config_network]')
        self.config_file.write("\n")
        self.config_file.write(self.config_network)
        self.config_file.write("\n")

    def _add_main(self):

        if self.public_ips:
            self.config_file.write('[public_main]')
            self.config_file.write("\n")
            self.config_file.write(self.main_public_ip)
            self.config_file.write("\n")

        self.config_file.write("\n")
        self.config_file.write('[private_main]')
        self.config_file.write("\n")
        self.config_file.write(self.main_private_ip)
        self.config_file.write("\n")
        self.config_file.write("\n")

    def _add_secondaries(self):

        if not self.private_secondaries: return

        self.config_file.write('[private-secondaries]')
        self.config_file.write("\n")

        for _ip in self.private_secondaries:
            self.config_file.write(_ip)
            self.config_file.write("\n")

        self.config_file.write("\n")

    def create(self):

        # [public]
        # 13.212.156.196
        # 13.212.111.66
        # 13.229.147.37
        # 
        # [public_main]
        # 13.212.156.196
        # 
        # [private-main]
        # 172.31.5.4
        # 
        # [private-secondaries]
        # 172.31.10.21
        # 172.31.1.231

        self._set_vars()
        #self._create_mongodb_keyfile()
        #self._create_mongodb_pem()
        self._add_public()
        self._add_private()
        self._add_config_ips()
        self._add_config_network()
        self._add_main()
        self._add_secondaries()
        self.config_file.close()
        self.logger.debug("Created Ansible host config file {}".format(self.config_file_path))

if __name__ == '__main__':

    main = Main()
    main.create()
