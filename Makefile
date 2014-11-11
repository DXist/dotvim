.PHONY: all
all: install update

.PHONY: fastupdate
fastupdate:
	vim +NeoBundleInstall +qall

.PHONY: update
update:
	vim +NeoBundleInstall! +qall

.PHONY: install
install:
	git clone git@github.com:Shougo/neobundle.vim.git bundle/neobundle.vim || ( cd bundle/neobundle.vim && git pull )
