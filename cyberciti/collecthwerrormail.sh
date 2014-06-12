  #!/bin/bash
    # Linux 64 bit kernel shell script to collect hardware errors via /var/log/mcelog
    # and send email alert.
    # -------------------------------------------------------------------------
    # Copyright (c) 2008 nixCraft project <http://cyberciti.biz/fb/>
    # This script is licensed under GNU GPL version 2.0 or above
    # -------------------------------------------------------------------------
    # This script is part of nixCraft shell script collection (NSSC)
    # Visit http://bash.cyberciti.biz/ for more information.
    # -------------------------------------------------------------------------
    # Tested under RHEL and Debian Linux 64 bit version.
    # mcelog must be installed.
    # See: http://www.cyberciti.biz/tips/linux-server-predicting-hardware-failure.html
    LOGGER=/usr/bin/logger
    FILE=/var/log/mcelog
    AEMAIL="vivek@nixcraft.net.in"
    ASUB="H/W Error - $(hostname)"
    AMESS="Warning - Hardware errors found on $(hostname) @ $(date). See log file for the details /var/log/mcelog."
    OK_MESS="$0 - OK: NO Hardware Error Found."
    WARN_MESS="$0 - ERROR: Hardware Error Found."
     
    die(){
    echo "$@"
    exit 999
    }
     
    warn(){
    echo $AMESS | email -s "${ASUB}" ${AEMAIL}
    $LOGGER "$WARN_MESS"
    }
     
    [ ! -f "$FILE" ] && die "Error - No $FILE exists or mcelog is not configured"
    [ $(grep -c -i "hardware error" $FILE) -gt 0 ] && warn || $LOGGER $OK_MESS
