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

        self.classname = 'OpenSSL'
        self.logger = get_logger(self.classname)[0]
        self.logger.debug("Instantiating %s" % self.classname)

        self.files_dir = kwargs["files_dir"]

        self.country = kwargs.get("country","US")
        self.country_state = kwargs.get("country_state","California")
        self.city = kwargs.get("city","SanFrancisco")
        self.cert_cn = kwargs.get("cert_cn","www.selfsigned.com")
        self.cert_length = kwargs.get("cert_length","1024")
        self.cert_bits = kwargs.get("cert_bits","2048")

    def _create_ssl(self):

        os.chdir(self.files_dir)

        cmd = 'openssl req -newkey rsa:{} -new -x509 -subj "/C={}/ST={}/L={}/O=Dis/CN={}" -days {} -nodes -out mongodb.crt -keyout mongodb.key'.format(self.cert_bits,
                                                                                                                                                       self.country,
                                                                                                                                                       self.country_state,
                                                                                                                                                       self.city,
                                                                                                                                                       self.cert_cn,
                                                                                                                                                       self.cert_length)

        execute(cmd,exit_error=True)

        cmd = 'bash -c \'cat mongodb.crt mongodb.key > mongodb.pem\''
        execute(cmd,exit_error=True)

    def _create_symmetric(self):

        os.chdir(self.files_dir)
        cmd = 'openssl rand -base64 756 > mongodb_keyfile'
        execute(cmd,exit_error=True)

    def create(self):

        self._create_symmetric()
        self._create_ssl()

if __name__ == '__main__':

    main = Main()
    main.create()
