#/usr/bin/env bash
# Print a list of libraries that have missing dependencies.

for i in $(find /usr/lib/ -iname '*.so*' -print 2>/dev/null)
do 
    not_found="$(ldd $i 2>/dev/null|grep "not found")"
    if [[ -n "$not_found" ]]
    then 
        printf "%s: %s\n" "$i" "$not_found"
    fi
done
