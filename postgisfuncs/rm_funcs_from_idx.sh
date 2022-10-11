#!/bin/bash

while read func
do
    if [ -n "$func" ]; then
        echo $func
#        sed -i "s/\(^.*$func[^\n]*$\)/# \1/g" /tools/postgis_migration/postgisfuncs/kvwmapsp_komp.idx
    fi
#    exit
done < <(psql postgres postgres -t < /tools/postgis_migration/postgisfuncs/postgisfuncs.sql)
