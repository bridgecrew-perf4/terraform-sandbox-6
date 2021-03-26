#!/usr/bin/env python

import os
import logging
from logging import config

def get_logger(name,**kwargs):

    # if stdout_only is set, we won't write to file
    stdout_only = kwargs.get("stdout_only")
    
    # Set loglevel
    loglevel = os.environ.get("LOGLEVEL","DEBUG")

    # Set logdir and logfile
    if not stdout_only:

        logdir = kwargs.get("LOGDIR","/tmp/main/")
        logfile = kwargs.get("LOGFILE","log")
        logfile_path = os.path.join(logdir,logfile)

        if not os.path.exists(logdir): os.system("mkdir -p {}".format(logdir))
        if not os.path.exists(logfile_path): os.system("touch {}".format(logfile_path))

    formatter = kwargs.get("formatter","module")
    name_handler = kwargs.get("name_handler","console,loglevel_file_handler,error_file_handler")

    # defaults for root logger
    logging.basicConfig(level=eval("logging.%s" % loglevel))
    name_handler = [ x.strip() for x in list(name_handler.split(",")) ]

    # Configure loglevel
    # Order of precedence:
    # 1 loglevel specified
    # 2 logcategory specified
    # 3 defaults to "debug"

    log_config = {"version":1}
    log_config["disable_existing_loggers"] = False

    log_config["formatters"] = {
        "simple": {
            "format": "%(asctime)s - %(levelname)s - %(message)s",
            "datefmt": '%Y-%m-%d %H:%M:%S'
        },
        "module": {
            "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
            "datefmt": '%Y-%m-%d %H:%M:%S'
        }
    }

    if stdout_only:

        log_config["handlers"] = {
            "console": {
                "class": "logging.StreamHandler",
                "level": loglevel,
                "formatter": formatter,
                "stream": "ext://sys.stdout"
            }
        }

    else:

        log_config["handlers"] = {
            "console": {
                "class": "logging.StreamHandler",
                "level": loglevel,
                "formatter": formatter,
                "stream": "ext://sys.stdout"
            },
            "info_file_handler": {
                "class": "logging.handlers.RotatingFileHandler",
                "level": "INFO",
                "formatter": formatter,
                "filename": logdir+"info.log",
                "maxBytes": "10485760",
                "backupCount": "20",
                "encoding": "utf8"
            },
            "loglevel_file_handler": {
                "class": "logging.handlers.RotatingFileHandler",
                "level": loglevel,
                "formatter": formatter,
                "filename": logdir+loglevel+".log",
                "maxBytes": "10485760",
                "backupCount": "20",
                "encoding": "utf8"
            },
            "error_file_handler": {
                "class": "logging.handlers.RotatingFileHandler",
                "level": "ERROR",
                "formatter": formatter,
                "filename": logdir+"errors.log",
                "maxBytes": "10485760",
                "backupCount": "20",
                "encoding": "utf8"
            }
        }

    log_config["loggers"] = {
        name: {
            "level": loglevel,
            "handlers": name_handler,
            "propagate": False 
        }
    }

    log_config["root"] = {
        "level": loglevel,
        "handlers": name_handler
    }

    config.dictConfig(log_config) 
    logger = logging.getLogger(name)
    logger.setLevel(eval("logging."+loglevel))

    return logger,name
