python << EOF
import os
import sys
if not sys.path.count('.'): sys.path.insert(0, '.')
os.environ['DJANGO_SETTINGS_MODULE'] = "settings"
EOF
