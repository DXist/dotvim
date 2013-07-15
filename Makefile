all:
	vim +BundleInstall! +qall

update:
	vim +BundleInstall +qall

install:
	git clone https://github.com/gmarik/vundle.git bundle/vundle
