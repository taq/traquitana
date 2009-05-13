# force the production enviroment
export RAILS_ENV=production

# move to the correct directory
cd $1/..

# make a copy of the old contents
echo Making a safe copy of the old contents ...
zip -q traq/$2.safe.zip `cat traq/$2.list`
echo Stored on traq/$2.safe.zip

# install the new files
echo
echo Unzipping the new content
echo -------------------------
unzip -o traq/$2.zip

# run migrations if needed
migrations=$(grep "^db/migrate" traq/$2.list)

if [ -n "$migrations" ]; then
	echo
	echo Running migrations
	echo ------------------
	rake db:migrate
fi

# restart the server
traq/server.sh
