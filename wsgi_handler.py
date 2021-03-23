#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This module loads the WSGI application specified by FQN in `.serverless-wsgi` and invokes
the request when the handler is called by AWS Lambda.

Author: Logan Raarup <logan@logan.dk>
"""
import importlib
import json
import os
import sys
import traceback

# Call decompression helper from `serverless-python-requirements` if
# available. See: https://github.com/UnitedIncome/serverless-python-requirements#dealing-with-lambdas-size-limitations
try:
    import unzip_requirements  # noqa
except ImportError:
    pass

import serverless_wsgi

def load_config():
    """ Read the configuration file created during deployment
    """
    root = os.path.abspath(os.path.dirname(__file__))
    with open(os.path.join(root, ".serverless-wsgi"), "r") as f:
        return json.loads(f.read())


def import_app(app):
    """ Load the application WSGI handler
    """
    wsgi_fqn = app.rsplit(".", 1)

    try:
        wsgi_module = importlib.import_module(wsgi_fqn[0])
        return getattr(wsgi_module, wsgi_fqn[1])
    except:  # noqa
        traceback.print_exc()
        raise Exception("Unable to import {}".format(app))

def handler(event, context):
    return serverless_wsgi.handle_request(wsgi_app, event, context)

def _create_app():
    return wsgi_app

app = os.environ.get("LAMBDA_HANDLER","lambda.lambda_handler")
wsgi_app = import_app(app)
