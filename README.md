# DeDup
DeDup-lication utility for macOS

Produce checksum file with following command on each file system which you want to compare. You can open then all the checksum files together with this utility to find out which files are the same on the particular filesystems: 

find /path/to/filesystem -type f -exec md5sum '{}' \; > output_checksum_file

Once you open the checksum files in this utility you will see the filesystem tree on the left side. Duplicates are coloured with green. Partial duplicates are coloured with shades of blue - the darker the colour is the more duplicates you will find inside the subtree.

Clicking the file you will get its hash and its duplicates in the view on the right side.

Feel free to contribute...
git clone https://github.com/wwwenca/DeDup
