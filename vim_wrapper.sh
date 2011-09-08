#!/bin/bash
export PROJECT=`python -c "import os; print os.path.basename(os.getcwd())"`
export PYTHONPATH=`python -c "import os; print os.path.realpath(os.path.join(os.getcwd(),'..'))"`
export DJANGO_SETTINGS_MODULE=$PROJECT.settings
export DJANGO_APP=anapp
vim $@
