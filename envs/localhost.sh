#!/usr/bin/env bash
#
# This is minimal configuration for CTRL <-> TRGT setup
#
# SSH key-based auth will be used to access "localhost" as the user "root"
#
export CIJ_TARGET_TRANSPORT="ssh"
export SSH_HOST=localhost
export SSH_USER=root
