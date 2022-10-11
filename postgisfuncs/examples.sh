#!/bin/bash

declare -a arr=("_postgis_index_extent(regclass, text)" "box2d(regclass, text)" "box3d(regclass, text)")

for func in "${arr[@]}"
do
    sed -i "s/\(^.*$func[^\n]*$\)/# \1/g" examples
done

