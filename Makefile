.PHONY: all

all: install update

.PHONY: update
update:
	vim +NeoBundleInstall! +qall

.PHONY: install
install:
	git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim || ( cd ~/.vim/bundle/neobundle.vim && git pull )
