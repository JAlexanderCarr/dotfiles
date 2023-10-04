SHELL := /bin/bash

DEBIAN-AMD64_DIR := debian-amd64
DEBIAN-ARM64_DIR := debian-arm64

-include debian-amd64/Makefile
-include debian-arm64/Makefile

check_home:
ifndef HOME_DIR
	$(error $$HOME_DIR directory is undefined)
endif

install_ssh:
	make check_home
	mkdir -p ${HOME_DIR}/.ssh
	ssh-keygen -q -f ${HOME_DIR}/.ssh/id_rsa

install_debian-amd64:
	make check_home
	make debian-amd64_packages
	make debian-amd64_files
	make debian-amd64_config

setup_debian-amd64:
	make install_debian-amd64
	make install_ssh

install_debian-arm64:
	make check_home
	make debian-arm64_packages
	make debian-arm64_files
	make debian-arm64_config

setup_debian-arm64:
	make install_debian-arm64
	make install_ssh
