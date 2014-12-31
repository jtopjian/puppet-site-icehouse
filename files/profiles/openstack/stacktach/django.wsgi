import logging
import os
import sys
import django.core.handlers.wsgi
from django.conf import settings

os.environ['DJANGO_SETTINGS_MODULE'] = 'settings'
os.environ['STACKTACH_INSTALL_DIR'] = '/usr/share/stacktach/'
sys.stdout = sys.stderr
# Add this file path to sys.path in order to import settings
sys.path.append("/usr/share/stacktach")

DEBUG = False

application = django.core.handlers.wsgi.WSGIHandler()
