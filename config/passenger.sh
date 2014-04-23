if [ -d tmp ]; then
   echo -n "Restarting Passenger ... "
   rm -f tmp/restart.txt
   touch tmp/restart.txt
fi
