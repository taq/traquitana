function msg() {
   local str="$1"
   local verbose="$2"
   local newline="$3"
   if [ "$verbose" != "true" ]; then
      return 1
   fi
   if [ "$newline" == "true" ]; then
      echo "$str"
   else
      echo -n "$str"
   fi
}

# force the production enviroment
export RAILS_ENV=production

# move to the correct directory
cd $1/..

# verbose mode
verbose="$3"

# make a copy of the old contents
msg "Making a safety copy of the old contents on traq/$2 ... " "$verbose" "false"
zip -q traq/$2.safe.zip `cat traq/$2.list` &> /dev/null
msg "done." "$verbose" "true"

# check the current Gemfile checksum
old_gemfile_md5=$(md5sum Gemfile 2> /dev/null | cut -f1 -d' ')

# install the new files
msg "Unzipping $2.zip ... " "true" "false"
unzip -o traq/$2.zip &> /dev/null
msg "done." "true" "true"

# check the new Gemfile checksum
new_gemfile_md5=$(md5sum Gemfile 2> /dev/null | cut -f1 -d' ')

# if the current Gemfile is different, run bundle install
if [ "$old_gemfile_md5" != "$new_gemfile_md5" ]; then
   msg "Running bundle install ..." "$verbose" "true"
   bundle install
fi

# run migrations if needed
migrations=$(grep "^db/migrate" traq/$2.list)
if [ -n "$migrations" ]; then
	msg "Running migrations ... " "true" "true"
	bundle exec rake db:migrate 2> /dev/null
   msg "Migrations done." "true" "true"
fi

# precompile assets if needed
if [ -d app/assets ]; then
   msg "Compiling assets ... " "$verbose" "false"
   bundle exec rake assets:precompile 2> /dev/null
   msg "done." "$verbose" "true"
fi

# change file permissions on public dir
if [ -d public ]; then
   msg "Changing file permissions on public to 0755 ... " "$verbose" "false"
   chmod -R 0755 public/*
   msg "done." "$verbose" "true"
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
