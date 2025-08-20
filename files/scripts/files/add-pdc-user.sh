#!/bin/bash
smbldap-useradd -m -a $1
smbldap-passwd $1
smbldap-usermod -H [XU] $1

