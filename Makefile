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
	git clone https://github.com/Shougo/neobundle.vim bundle/neobundle.vim || ( cd bundle/neobundle.vim && git pull )
