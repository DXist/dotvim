all:
	vim +BundleInstall! +qall
	cd ./bundle/YouCompleteMe/ && ./install.sh

update:
	vim +BundleInstall +qall

install:
	git clone https://github.com/gmarik/vundle.git bundle/vundle
