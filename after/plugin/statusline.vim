" statusline
set statusline=
if exists("*lighthouse#statusline")
	set statusline+=%{lighthouse#statusline()}\ 
endif

if exists("*virtualenv#statusline")
	set statusline+=%{virtualenv#statusline()}\ 
endif

if exists("*fugitive#statusline")
	set statusline+=%{fugitive#statusline()}\ 
endif

set statusline+=%<%f\ %y\ [tw:\ %{&textwidth}]\ %h%m%r%=%-14.(%l,%c%V%)\ %P\ 

if exists("*SyntasticStatuslineFlag")
    set statusline+=%#warningmsg#
	set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
endif
