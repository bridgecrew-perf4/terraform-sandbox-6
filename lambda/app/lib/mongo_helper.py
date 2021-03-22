#!/usr/bin/env python
#
#Written by Gary Leong  <gwleong@gmail.com, September 17,2020

#client = pymongo.MongoClient('mongodb://<sample-user>:<password>@sample-cluster.node.us-east-1.docdb.amazonaws.com:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false')

#from pymongo import MongoReplicaSetClient

import os
from time import sleep
from ssl import CERT_NONE
from pymongo import MongoClient
from pymongo import ASCENDING
from pymongo import DESCENDING
from gridfs import GridFS

class MongoDbHelper(object):

    def __init__(self,database,**kwargs):

        self.classname = 'MongoDbHelper'
        print("Instantiating native %s" % self.classname)

        _host = kwargs.get('ipaddress',kwargs.get("host","localhost"))
        _port = int(kwargs.get('port',27017))
        _ssl = kwargs.get("ssl",True)

        _user = kwargs.get('username',kwargs.get("user"))
        _passwd = kwargs.get('password')

        #print("database: %s" % database)
        #print("host: %s" % _host)
        #print("user: %s" % _user)
        #print("port: %s" % _port)
        #print("ssl: %s" % _ssl)

        self.db_connection = False

        conn_str = 'mongodb://{}:{}@{}:27017/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false'.format(_user,
                                                                                                                         _passwd,
                                                                                                                         _host)

        #conn_str = 'mongodb://{}:{}@{}:27017/?ssl=true&ssl_ca_certs=ca-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false'.format(_user,
        #                                                                                                                                                     _passwd,
        #                                                                                                                                                     _host)
 
        self.connection = MongoClient(conn_str,ssl_cert_reqs=CERT_NONE)

        if not self.connection:
            msg = "There is no connection to mongo"
            raise Exception(msg)

        print("mongo connection initiated and successful")

        #self.db_connection = self.connection.injection

        self.set_database(database)

        print("mongo db connection initiated and successful")
        #print("")
        #print("    {}".format(self.db_connection))
        #print("")

    def set_database(self,database):

        try:
            self.db_connection = self.connection[database]
        except:
            msg = "Cannot get connection to database {}".format(database)
            raise Exception(msg)

        try:
            self.fs = GridFS(self.db_connection)
        except:
            msg = "Could not establish connection to GridFS - may not be needed"
            print(msg)

    def insert(self,collection,values,w=1):

        '''
        does a insert of values into a collection, where values is a dict or
        json format.  this does not update docs, but is useful for 
        bulk inserts
        '''

        db = self.db_connection[collection]

        if isinstance(values,list):
            oid = db.insert_many(values)
        else:
            oid = db.insert(values,w=w)

        return oid
    
    def save(self,collection,values):

        '''
        does a save of values into a collection, where values is a dict or
        json format
        '''

        db = self.db_connection[collection]
        oid = db.save(values)

        return oid

    def find(self,collection,match):
        db = self.db_connection[collection]
        return db.find(match)

    def search(self,collection,match,sort_key=None,ascending=True):

        '''
        a more general find function that offers sorting and ascending/descending
        '''
        db = self.db_connection[collection]

        #if sort key is not provided, we use the default sort key
        if not sort_key:
            if ascending:
                post = db.find(match).sort("_id",ASCENDING)
            else:
                post = db.find(match).sort("_id",DESCENDING)

        elif isinstance(sort_key,str):
            if ascending:
                post = db.find(match).sort(sort_key,ASCENDING)
            else:
                post = db.find(match).sort(sort_key,DESCENDING)  

        elif isinstance(sort_key,list):
            post = db.find(match).sort(sort_key)

        return post

    def remove(self,collection,match):

        '''
        removes the match
        '''

        db = self.db_connection[collection]
        print("Attempting to remove match = {} from collection = {}".format(match,collection))

        oid = db.remove(match)
        count = int(oid["n"])

        if count >= 1:
            print('{} count={} was deleted in collection="{}"'.format(match,count,collection))
            return True
        else:
            print('{} was not deleted in collection="{}"'.format(match,collection))
            return None

    def ensure_index(self,collection,field,expireAfterSeconds=None,unique=None):

        db = self.db_connection[collection]

        input_args = {}
        if expireAfterSeconds: input_args["expireAfterSeconds"] = int(expireAfterSeconds)
        if unique: input_args["unique"] = unique

        return db.ensure_index([(field, ASCENDING)],**input_args)

    def create_collection(self,collection,size=None,capped=None):

        input_args = {}
        if size: input_args["size"] = int(size)
        if capped: input_args["capped"] = capped

        self.db_connection.create_collection(collection,**input_args)

    def find_and_modify(self,collection,match,update_values=None,sort=None,**kwargs):

        db = self.db_connection[collection]
        input_args = {}

        if update_values: input_args["update"] = {"$set":update_values}
        if not sort: sort = [ ('_id', DESCENDING) ]
        input_args["sort"] = sort

        return db.find_and_modify(match,**input_args)

    def push_one(self,collection,match,col_update,add_value,upinsert=True,unique=True):

        db = self.db_connection[collection]

        if not unique:
            return db.update_one(match,{'$push': {col_update:add_value}},upsert=upinsert)
        else:
            return db.update_one(match,{'$addToSet': {col_update:add_value}},upsert=upinsert)

    def push(self,collection,match,col_update,add_values,upinsert=True,unique=True):

        db = self.db_connection[collection]

        if not unique:
            return db.update(match,{'$push': {col_update:add_values}},upsert=upinsert)
        else:
            return db.update(match,{'$addToSet': {col_update:add_values}},upsert=upinsert)

    def pull_one(self,collection,match,col_pull,direction=-1):
        db = self.db_connection[collection]
        return db.update(match,{'$pop': {col_pull:direction}})
