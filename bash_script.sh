

copy_to_location()
{
    ((count=1))
    nfl=$( cat "$starting_dir/log.txt" | wc -l | cut -d " " -f 1 )
    while [ "$count" -lt "$((nfl+1))" ] ;do
        file="$( cat "$starting_dir/log.txt" | head -n $count | tail -n 1 )"
        ((count2=${#starting_dir}))
        new_path="$( echo "$file" | cut -c $(($count2+2))- )"
        new_path_create=$( echo $new_path | rev | cut --complement -d "/" -f 1 | rev )
        if [ -d "$new_path_create" > /dev/null ] ;then
            echo "Creating directory $write_location/$new_path_create"
            mkdir -p "$write_location/$new_path_create"
            echo "Copying $( echo "$file" | rev | cut -d "/" -f 1 | rev )....."
            cp "$file" "$write_location/$new_path_create"
        else
            echo "Copying $( echo "$file" | rev | cut -d "/" -f 1 | rev )....."
            cp "$file" "$write_location"
        fi
        ((count++))
    done
}

filter_uniq_files()
{
    cd "$1"
    echo "Looking for files in $1......."
    ((count1=1))
    while [ "$count1" -lt "$(($( ls -1 "$1" | wc -l | cut -d " " -f 1 )+1))" ] ;do
        file1="$( ls -1 "$1" | head -n $count1 | tail -n 1 )"
        if [ X"$( file "$file1" | cut -d ":" -f 2 | cut -d " " -f 2 )" = X"directory" ] ;then
            ( filter_uniq_files "$1/$file1" )
            ((count1++))
            continue
        fi
        cd "$1"
        ((count2=1))
        if [ $count1 -eq "1" ] ; then
            if [ X"$( wc -m "$starting_dir/log.txt" | cut -d " " -f 1 )" = X"0" ] ;then
                cd "$starting_dir"
                echo "$1/$file1" >> "log.txt"
                cd "$1"
            fi
        fi
        nf=$( cat "$starting_dir/log.txt" | wc -l | cut -d " " -f 1 )
        ((found=0))
        while [ "$count2" -lt  $((nf+1)) ] ;do
            file2="$( cat "$starting_dir/log.txt" | head -n $count2 | tail -n 1 )"
            ((count2++))
            if [ "$( diff "$file1" "$( echo "$file2" )" )" ] ;then
                echo . > /dev/null
            else 
                ((found++))
            fi
        done
        if [ $found == 0 ] ;then
            cd "$starting_dir"
            echo "$1/$file1" >> "log.txt"
            cd "$1"
        fi
        ((count1++))
    done
}

starting_dir="$1"
mkdir "$1/Cleaned"
write_location="$starting_dir/Cleaned"
filter_uniq_files "$starting_dir"
copy_to_location "$write_location"
