#!/bin/bash

# is not testet
file=$1


# 600 ist unbedingt notwendig !!
if [ ! -e && ! -r $file  ] ; then
  chmod 600 ./authkeys
fi

exit 0
