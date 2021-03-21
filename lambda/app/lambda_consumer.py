#!/usr/bin/env python

import os
#from __future__ import print_function
from lib.mongo_helper import MongoDbHelper
import json

print('Loading injection function')

class Main(object):
      
    def __init__(self,**kwargs):

        self.classname = "Main"
        self._set_db_conn(**kwargs)

        self.collection = "transform"

    def _set_db_conn(self,**kwargs):

        mongod_username = os.environ.get("MONGO_USERNAME","admin123")
        mongod_password = os.environ.get("MONGO_PASSWORD","admin123")
        auth_db = os.environ.get("MONGO_AUTH_DB")

        host = os.environ["MONGO_ENDPOINT"]
        database = os.environ.get("MONGO_DATABASE","injection")

        inputargs = {"username":mongod_username,
                     "password":mongod_password,
                     "host":host}

        if auth_db: inputargs["auth_db"] = auth_db
        self.db = MongoDbHelper(database,**inputargs)

    def inject(self,**kwargs):

        number = int(kwargs["number"])
        values = kwargs

        try:
            values["new_number"] = number + 10
        except:
            print("Could not transform the number given - not a integer")

        print("Looking to insert values {}.".format(values))

        oid = self.db.save(self.collection,values)

        print("inserted/save values {} with oid {}.".format(values,oid))

        return oid

def lambda_handler(event, context):

    if not isinstance(event,dict):
        try:
            message = json.loads(event['Records'][0]['Sns']['Message'])
        except:
            print("WARN: could not convert to json")
            message = event['Records'][0]['Sns']['Message']
    else:
        message = event['Records'][0]['Sns']['Message']

    if not isinstance(message,dict):
        message = eval(message)

    print("")
    print("")
    print("From SNS: {}".format(message))
    print("")
    print("")
    
    main = Main()
    #print("")
    #print(message)
    #print("")
    #print(type(message))
    #print("")
    main.inject(**message)
