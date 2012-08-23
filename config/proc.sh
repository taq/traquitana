# force the production enviroment
export RAILS_ENV=production

# move to the correct directory
cd $1/..

# verbose mode
verbose="$3"

# make a copy of the old contents
if [ "$verbose" == "true" ]; then
   echo -n "Making a safety copy of the old contents on traq/$2 ... "
fi   
zip -q traq/$2.safe.zip `cat traq/$2.list` &> /dev/null
if [ "$verbose" == "true" ]; then
   echo "done."
fi   

# check the current Gemfile checksum
old_gemfile_md5=$(md5sum Gemfile 2> /dev/null | cut -f1 -d' ')

# install the new files
echo -n "Unzipping $2.zip ... "
unzip -o traq/$2.zip &> /dev/null
echo "done."

# check the new Gemfile checksum
new_gemfile_md5=$(md5sum Gemfile 2> /dev/null | cut -f1 -d' ')

# if the current Gemfile is different, run bundle install
if [ "$old_gemfile_md5" != "$new_gemfile_md5" ]; then
   if [ "$verbose" == "true" ]; then
      echo "Running bundle install ..."
   fi   
   bundle install
fi

# run migrations if needed
migrations=$(grep "^db/migrate" traq/$2.list)
if [ -n "$migrations" ]; then
	echo "Running migrations ... "
	bundle exec rake db:migrate 2> /dev/null
   echo "Migrations done."
fi

# precompile assets if needed
if [ -d app/assets ]; then
   if [ "$verbose" == "true" ]; then
      echo -n "Compiling assets ... "
   fi   
   bundle exec rake assets:precompile 2> /dev/null
   if [ "$verbose" == "true" ]; then
      echo "done."
   fi   
fi

# change file permissions on public dir
if [ "$verbose" == "true" ]; then
   echo -n "Changing file permissions on public to 0755 ... "
fi
chmod -R 0755 public/*
if [ "$verbose" == "true" ]; then
   echo "done."
fi

# restart server
if [ -x ./traq/server.sh -a -f ./traq/server.sh ]; then
   ./traq/server.sh
fi   

# extra configs
if [ -x ./traq/extra.sh -a -f ./traq/extra.sh ]; then
   ./traq/extra.sh
fi

# erase file
rm traq/$2.zip
