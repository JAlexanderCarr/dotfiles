SHELL := /bin/bash

DEBIAN-X86_DIR := debian-x86
DEBIAN-ARM_DIR := debian-arm

-include debian-x86/Makefile
-include debian-arm/Makefile

check_home:
ifndef HOME_DIR
	$(error $$HOME_DIR directory is undefined)
endif

install_ssh:
	make check_home
	mkdir -p ${HOME_DIR}/.ssh
	ssh-keygen -q -f ${HOME_DIR}/.ssh/id_rsa

install_debian-x86:
	make check_home
	make debian-x86_packages
	make debian-x86_files
	make debian-x86_config

setup_debian-x86:
	make install_debian-x86
	make install_ssh

install_debian-arm:
	make check_home
	make debian-arm_packages
	make debian-arm_files
	make debian-arm_config

setup_debian-arm:
	make install_debian-arm
	make install_ssh
