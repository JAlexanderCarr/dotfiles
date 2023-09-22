SHELL := /bin/bash

DEBIAN-X86_DIR := debian-x86

-include debian-x86/Makefile

check_home:
ifndef HOME
	$(error $$HOME directory is undefined)
endif

install_ssh:
	make check_home
	mkdir -p ${HOME}/.ssh
	ssh-keygen -q -f ${HOME}/.ssh/id_rsa

install_debian-x86:
	make check_home
	make debian-x86_packages
	make debian-x86_files
	make debian-x86_config

setup_debian-x86:
	make install_debian-x86
