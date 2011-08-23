# force the production enviroment
export RAILS_ENV=production

# move to the correct directory
cd $1/..

# make a copy of the old contents
echo Making a safe copy of the old contents ...
zip -q traq/$2.safe.zip `cat traq/$2.list` &> /dev/null
echo Stored on traq/$2.safe.zip

# install the new files
echo
echo Unzipping the new content
echo -------------------------
unzip -o traq/$2.zip &> /dev/null

# run migrations if needed
migrations=$(grep "^db/migrate" traq/$2.list)

if [ -n "$migrations" ]; then
	echo
	echo Running migrations
	echo ------------------
	rake db:migrate
fi

# change file permissions on public dir
echo 
echo Changing file permissions on public to 0755
echo -------------------------------------------
chmod -R 0755 public/*
echo Changed.

# restart the server
traq/server.sh
