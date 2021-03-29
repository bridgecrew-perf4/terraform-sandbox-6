#!/usr/bin/env python
#

import os
import string
import random
import json
import datetime

class DateTimeJsonEncoder(json.JSONEncoder):

    def default(self,obj):

        if isinstance(obj,datetime.datetime):
            #newobject = str(obj.timetuple())
            newobject = '-'.join([ str(element) for element in list(obj.timetuple())][0:6])
            return newobject

        return json.JSONEncoder.default(self,obj)

def print_json(results):
    print json.dumps(results,sort_keys=True,cls=DateTimeJsonEncoder,indent=4)

def get_random(size=6,chars=string.ascii_uppercase+string.digits):

    return ''.join(random.choice(chars) for x in range(size))

def get_dict_frm_file(file_path):

    params = {}

    rfile = open(file_path,"r")

    non_blank_lines = (line.strip() for line in rfile.readlines() if line.strip())

    for bline in non_blank_lines:
        key,value = bline.split("=")
        params[key] = value

    return params

def mkdir(directory):

    try:
        if not os.path.exists(directory):
            os.system("mkdir -p %s" % (directory))
        return True
    except:
        return False

def rm_rf(location):

    if not location: return False

    try:
        os.remove(location)
        status = True
    except:
        status = False

    if status is False and os.path.exists(location):
        try:
            os.system("rm -rf %s > /dev/null 2>&1" % (location))
            return True
        except:
            print "problems with removing %s" % location
            return False

def execute5(command,exit_error=None):

    _return = os.system(command)

    # Calculate the return value code
    exitcode = int(bin(_return).replace("0b", "").rjust(16, '0')[:8], 2)

    if exitcode != 0 and exit_error: 
        raise RuntimeError('The system command\n{}\nexited with return code {}'.format(command,exitcode))

    results = {"status":True}

    if exitcode != 0:
        results = {"status":False}

    results["exitcode"] = exitcode

    return results
