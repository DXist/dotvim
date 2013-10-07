"Настройки табов для Python, согласно рекомендациям
setlocal expandtab "Ставим табы пробелами
setlocal softtabstop=4 "4 пробела в табе
"Ширина текста 79 символов
setlocal textwidth=79
setlocal commentstring=#%s
if v:version>=703
	setlocal cc=79
endif
let b:delimitMate_smart_quotes = 0

python << EOF
import os
import sys
import vim

if not sys.path.count('.'): sys.path.insert(0, '.')
for p in sys.path:
    # Add each directory in sys.path, if it exists.
    if os.path.isdir(p):
        # Command 'set' needs backslash before each space.
        vim.command(r"set path+=%s" % (p.replace(" ", r"\ ")))
EOF
