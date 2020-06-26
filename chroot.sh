#!/bin/bash

#Usage : ./chroot.sh <path> <commands>
#Example : ./chroot /srv/chroot bash id whoami ls
#Create a chroot at <path> 
#If <commands> is empty there will be only bash created in the chroot
#You must specify at least bash if <commands> isn’t empty
path=$1

mkdir -p $path

#Get every arguments except the first one
for command in $*
do
    if [ $command != $1 ]
    then
        location_full_path=`whereis $command | cut -d ' ' -f2`
        location=`echo $location_full_path | rev | cut -d '/' -f2-20 | rev`
        
        mkdir -p $path$location
        cp $location_full_path $path$location

        i=0

        #Read the command line by line
        ldd $location_full_path | while read -r lib;
        do
            #Skip the first line
            if [ $i -ne 0 ]
            then
                library=`echo $lib | cut -d '/' -f2-20 | cut -d ' ' -f1`
                library_location=/`echo $library | rev | cut -d '/' -f2-20 | rev`

                mkdir -p $path$library_location
                cp /$library $path$library_location

            fi
            ((i=i+1))    #i++

        done
    fi
done