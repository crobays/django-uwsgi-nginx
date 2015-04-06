from development import *
import os

def custom_show_toolbar(self):
    return True

DEBUG_TOOLBAR_CONFIG = {
    'SHOW_TOOLBAR_CALLBACK': custom_show_toolbar,
}

DATABASES['default']['HOST'] = os.environ.get('DB_PORT_3306_TCP_ADDR')
DATABASES['default']['NAME'] = os.environ.get('DB_ENV_DATABASE')
DATABASES['default']['USER'] = os.environ.get('DB_ENV_USER')
DATABASES['default']['PASSWORD'] = os.environ.get('DB_ENV_PASS')