#!/usr/bin/env python

import os
import boto3
#from __future__ import print_function
import string
import random
import json
from time import time
from time import sleep

print('Loading injection function')

class Main(object):
      
    def __init__(self,**kwargs):

        self.classname = "Main"
        self.sns_topic = os.environ.get("SNS_TOPIC","injection")

        print("initiating connection to sns topic {}".format(self.sns_topic))
        self.sns_client = boto3.client('sns')

        #self.sns_client = boto3.client('sns',
        #                               aws_access_key_id=sns_access_key,
        #                               aws_secret_access_key=sns_secret_key)

    def _get_random_num(self,size=6,chars=string.ascii_uppercase+string.digits):
        return ''.join(random.choice(chars) for x in range(size))

    def _insert(self,**kwargs):

        number = random.randint(10000,11000)
        rstr = self._get_random_num(size=6,chars=string.ascii_uppercase+string.digits)
        epoch_time = str(int(time()))

        message = {"_id":rstr}
        message["number"] = number
        message["epoch_time"] = epoch_time

        print("inserting message {}".format(message))

        response = self.sns_client.publish(TargetArn=self.sns_topic,
                                           Message=json.dumps({'default':json.dumps(message)}),
                                           MessageStructure='json'
                                           )

        return response

    def insert(self,**kwargs):

        #return self._insert(**kwargs)

        while True:
            self._insert(**kwargs)
            sleep(1)


def lambda_handler(event, context):

    main = Main()
    main.insert()

if __name__ == '__main__':

    main = Main()
    main.insert()
