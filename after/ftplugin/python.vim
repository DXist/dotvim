"Настройки табов для Python, согласно рекомендациям
setlocal expandtab "Ставим табы пробелами
setlocal softtabstop=4 "4 пробела в табе
setlocal cc=79
python << EOF
import os
import sys
import vim
for p in sys.path:
    # Add each directory in sys.path, if it exists.
    if os.path.isdir(p):
        # Command 'set' needs backslash before each space.
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
EOF
