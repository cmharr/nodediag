#!/bin/bash
##############################################################################
# Copyright (c) 2010, Lawrence Livermore National Security, LLC.
# Produced at the Lawrence Livermore National Laboratory.
# Written by Jim Garlick <garlick@llnl.gov>.
# LLNL-CODE-461827
# All rights reserved.
# 
# This file is part of nodediag.
# For details, see http://code.google.com/p/nodediag.
# Please also read the files DISCLAIMER and COPYING supplied with nodediag.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License (as published by the
# Free Software Foundation) version 2, dated June 1991.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the IMPLIED WARRANTY OF
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# terms and conditions of the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
##############################################################################

PATH=/sbin:/bin:/usr/sbin:/usr/bin

declare -r description="Check EDAC ECC type"
declare -r sanity=1

source ${NODEDIAGDIR:-/etc/nodediag.d}/functions

getecctype()
{
    local file

    shopt -s nullglob
    for file in /sys/devices/system/edac/mc/mc*/csrow*/edac_mode; do
        cat $file
    done
    shopt -u nullglob
}

diagconfig ()
{
    local ecctype=`getecctype | tail -1`

    [ -z "$ecctype" ] && return 1
    echo "DIAG_ECC_TYPE=\"$ecctype\""
}

diag_handle_args "$@"
diag_check_defined "DIAG_ECC_TYPE"

for ecctype in `getecctype`; do
    if [ "$ecctype" != $DIAG_ECC_TYPE ]; then
        diag_fail "$ecctype, expected $DIAG_ECC_TYPE"
    else
        diag_ok "$ecctype"
    fi
done
diag_fail "ECC is not enabled" 
