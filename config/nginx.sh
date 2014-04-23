if [ -d tmp ]; then
   echo -n "Restarting Nginx ... "
   rm -f tmp/restart.txt
   touch tmp/restart.txt
fi   
