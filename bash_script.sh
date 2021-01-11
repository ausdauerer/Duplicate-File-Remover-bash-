display_files()
{
    echo "$(cat uniqfileslog.txt | rev | cut -d "/" -f 1 | rev )"
}
update_file_count()
{
    value=$( cat "$starting_dir/temp.txt" | head -n 1 )
    value=$((value+1))
    echo "$value" > "$starting_dir/temp.txt"
}
display_progress()
{
    value=$( cat "$starting_dir/temp.txt" | head -n 1 )
    progress_percent=$(( ($value*100)/$nof ))
    progress_bar "$progress_percent"
    echo -ne "$1\r"
}
progress_bar()
{
    value="$1"
    value=$((value/2))
    string="[ "
    i=0
    while [ "$i" -le "$value" ];do
        string="$string#"
        ((i++))
    done
    while [ "$i" -le "50" ];do
        string="$string "
        ((i++))
    done
    string="$string ] $1%  "
    echo -ne "$string"
}
copy_to_location()
{
    ((count=1))
    nfl=$( cat "$starting_dir/uniqfileslog.txt" | wc -l | cut -d " " -f 1 )
    while [ "$count" -lt "$((nfl+1))" ] ;do
        update_file_count
        file="$( cat "$starting_dir/uniqfileslog.txt" | head -n $count | tail -n 1 )"
        ((count2=${#starting_dir}))
        new_path="$( echo "$file" | cut -c $(($count2+2))- )"
        echo -ne "\033[2K"
        #echo $new_path
        new_path_create=$( echo $new_path | rev | cut --complement -d "/" -f 1 | rev )
        display_progress "Copying file $file to $new_path_create"
        if [ -d "$new_path_create" > /dev/null ] ;then
            if [ ! -e "$write_location/$new_path_create" ];then
                echo -ne "\033[2K"
                display_progress "Creating directory $write_location/$new_path_create"
                mkdir -p "$write_location/$new_path_create"
            fi
            #echo "Copying $( echo "$file" | rev | cut -d "/" -f 1 | rev )....."
            cp "$file" "$write_location/$new_path_create"
        else
            #echo "Copying $( echo "$file" | rev | cut -d "/" -f 1 | rev )....."
            cp "$file" "$write_location"
        fi
        ((count++))
    done
}

filter_uniq_files()
{
    firstline="no"
    cd "$1"
    #echo "Looking for files in $1......."
    ((count1=1))
    while [ "$count1" -lt "$(($( ls -1 "$1" | wc -l | cut -d " " -f 1 )+1))" ] ;do
        file1="$( ls -1 "$1" | head -n $count1 | tail -n 1 )"
        #echo $file1
        if [ X"$file1" = X"uniqfileslog.txt" ] ;then
            ((count1++))
            continue
        fi
        if [ X"$( file "$file1" | cut -d ":" -f 2 | cut -d " " -f 2 )" = X"directory" ] ;then
            ( filter_uniq_files "$1/$file1" )
            if [ "$(ls "$1/$file1" | wc -l)" -eq 0 ] ;then
                display_progress "Removing Directory $file1"
                rmdir "$file1"
                ((count1--))
            fi
            ((count1++))
            continue
        fi
        cd "$1"
        ((count2=1))
        if [ $count1 -eq "1" ] ; then
            if [ X"$( wc -m "$starting_dir/uniqfileslog.txt" | cut -d " " -f 1 )" = X"0" ] ;then
                cd "$starting_dir"
                echo "$1/$file1" >> "uniqfileslog.txt"
                firstline="yes"
                cd "$1"
            fi
        fi
        update_file_count
        echo -ne "\033[2K"
        display_progress "Searching for files in $1......."
        nf=$( cat "$starting_dir/uniqfileslog.txt" | wc -l | cut -d " " -f 1 )
        ((found=0))
        while [ "$count2" -lt  $((nf+1)) ] ;do
            file2="$( cat "$starting_dir/uniqfileslog.txt" | head -n $count2 | tail -n 1 )"
            #echo file2- $file2
            ((count2++))
            if [ "$( diff "$file1" "$( echo "$file2" )" )" ] ;then
                echo . > /dev/null
            else 
                ((found++))
            fi
        done
        if [ $found == 0 ] ;then
            cd "$starting_dir"
            echo "$1/$file1" >> "uniqfileslog.txt"
            cd "$1"
        else
            if [ X"$optional" = X"" ] ;then
                if [ "$count1" == 1 ] && [ "$firstline" = "yes" ];then
                    echo . >> /dev/null
                    firstline="no"
                else
                    rm "$file1"
                    display_progress "Removing file $file1"
                    ((count1--))
                fi
            fi
        fi
        ((count1++))
    done
}

initialize(){
    nof=$(find  "$starting_dir" -type f | wc -l)
    echo "0" > "$starting_dir/temp.txt"
}
initialize_copy()
{
    nof=$( cat "$starting_dir/uniqfileslog.txt" | wc -l )
    echo "0" > "$starting_dir/temp.txt"
}
starting_dir=""
optional=""
nof=0
if [ X"$(echo $* | cut -d " " -f 1 | cut -c 1)" = X"-" ] ;then
    optional=$(echo $1 | cut --complement -c 1 )
fi

case "$optional" in 
"") 
    starting_dir="$1"
    > "$starting_dir/uniqfileslog.txt"
    initialize
    echo -e "Removing Dulplicate files\n"
    filter_uniq_files "$starting_dir" "$optional"
    echo -ne "\033[2K\r"
    rm "$starting_dir/temp.txt"
    echo Done
;;
"wtd")
    shift
    starting_dir="$1"
    shift
    write_location="$1"
    touch "$starting_dir/uniqfileslog.txt"
    > "$starting_dir/uniqfileslog.txt"
    #echo "" > uniqfileslog.txt
    initialize
    echo -e "Searching for Files\n"
    filter_uniq_files "$starting_dir"
    echo -ne "\033[2K\r"
    echo -e "Copying Files"
    initialize_copy
    copy_to_location "$write_location"
    echo -ne "\033[2K\r"
    rm "$starting_dir/uniqfileslog.txt"
    rm "$starting_dir/temp.txt"
    echo Done
;;
"lt")
    shift 
    starting_dir="$1"
    touch "$starting_dir/uniqfileslog.txt"
    initialize
    echo -e "Searching for Files\n"
    filter_uniq_files "$starting_dir"
    #cat "$starting_dir/uniqfileslog.txt"
    echo -ne "\033[2K\r"
    echo -e "These are the unique files , each with a different content\n\n"
    display_files
    rm "$starting_dir/uniqfileslog.txt"
    rm "$starting_dir/temp.txt"
    echo Done
;;
*) echo "Error: No Such optional Found" ;;
esac
