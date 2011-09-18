" statusline
set statusline=
if exists("*GetCurrentProject")
	set statusline+=Project:\ %{GetCurrentProject()}\ 
endif

if exists("*fugitive#statusline")
	set statusline+=%{fugitive#statusline()}\ 
endif

set statusline+=%<%f\ %y\ %h%m%r%=%-14.(%l,%c%V%)\ %P
