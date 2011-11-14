"Настройки табов для Python, согласно рекомендациям
setlocal expandtab "Ставим табы пробелами
setlocal softtabstop=4 "4 пробела в табе
"Ширина текста 79 символов
setlocal textwidth=79
if v:version>=703
	setlocal cc=79
endif

call snipMate_python_demo#Activate()

python << EOF
import os
import sys
import vim

if 'VIRTUAL_ENV' in os.environ:
    project_base_dir = os.environ['VIRTUAL_ENV']
    if not sys.path.count(project_base_dir):
        sys.path.insert(0, project_base_dir)
    activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))

if not sys.path.count('.'): sys.path.insert(0, '.')
os.environ['DJANGO_SETTINGS_MODULE'] = "settings"
for p in sys.path:
    # Add each directory in sys.path, if it exists.
    if os.path.isdir(p):
        # Command 'set' needs backslash before each space.
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
EOF
