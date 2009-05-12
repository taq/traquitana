echo
echo Restarting Passenger
echo --------------------
# sometimes passenger needs a "forced" tip to restart - removing the file first
rm -f tmp/restart.txt
touch tmp/restart.txt
echo Ok.
