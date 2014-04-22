#
# Show a message
# msg(message, verbose, newline)
#
function msg() {
   local str="$1"
   local verbose="$2"
   local newline="$3"

   echo "$str" >> $logfile
   if [ "$verbose" != "true" ]; then
      return 1
   fi

   if [ "$newline" == "true" ]; then
      echo "$str"
   else
      echo -n "$str"
   fi
}

#
# Show usage
#
function usage() {
   echo "Usage:"
   echo ""
   echo "proc.sh <traq directory> <id> <verbose>"
   echo ""
   echo "-h Show this message"
   echo "-o Show gem dir owner, detecting if using RVM"
   echo "-r Show gem dir owner, asking RVM"
   echo "-g Show gem dir owner, asking Rubygems"
   echo "-k Show Gemfile checksum"
}

#
# Return the RVM gems dir owner
#
function rvm_owner() {
   echo $(stat --printf=%U $(rvm gemdir))
}

#
# Return the gems dir owner
#
function gem_owner() {
   echo $(stat --printf=%U $(gem environment | grep INSTALLATION | cut -f2- -d:))
}

#
# Find the current gem owner
# If not using RVM, returns the owner of the gem directory
#
function gemdir_owner() {
   local owner=""
   if [ -n "$(which rvm)" ]; then
      owner=$(rvm_owner)
   else
      owner=$(gem_owner)
   fi
   echo ${owner}
}

#
# Gemfile checksum
#
function gemfile_checksum() {
   echo $(md5sum Gemfile 2> /dev/null | cut -f1 -d' ')
}

#
# Move to the app directory
#
function cd_app_dir() {
   msg "Moving to ${dir} directory ..." "${verbose}" "${newline}"
   cd $1/..
}

#
# Make a copy of the old contents
#
function safe_copy() {
   msg "Making a safety copy of the old contents on traq/$1.safe.zip ... " "$verbose" "false"
   zip -q traq/$1.safe.zip `cat traq/$1.list` &> /dev/null
   msg "done." "$verbose" "true"
}

#
# Install the new files
#
function install_new_files() {
   msg "Unzipping $1.zip ... " "true" "false"
   unzip -o traq/$1.zip &> /dev/null
   msg "done." "true" "true"
}

#
# Run migrations if needed
#
function migrate() {
   migrations=$(grep "^db/migrate" traq/${config_id}.list)
   if [ -n "$migrations" ]; then
      msg "Running migrations ... " "true" "true"
      bundle exec rake db:migrate 2> /dev/null
      msg "Migrations done." "true" "true"
   fi
}

#
# Precompile assets if needed
#
function assets() {
   if [ -d app/assets ]; then
      msg "Compiling assets ... " "$verbose" "false"
      bundle exec rake assets:precompile 2> /dev/null
      msg "done." "$verbose" "true"
   fi
}

#
# Change file permissions on public dir
#
function permissions() {
   if [ -d public ]; then
      msg "Changing file permissions on public to 0755 ... " "$verbose" "false"
      chmod -R 0755 public/*
      msg "done." "$verbose" "true"
   fi
}

#
# Fix current gems
#
function fix_gems() {
   msg "Fixing gems ..." "$verbose" "true"
   local owner=$(gemdir_owner)
   local curdir=$(pwd)
   # TODO: check if rvm or local gem dir is used
   local conf=$(rvm gemdir | cut -f1-3 -d/)
   msg "Gem dir owner is ${owner}" "$verbose" "true"

   # install gems system wide
   if [ "${owner}" == "root" ]; then
      msg "Performing a system wide gem install" "$verbose" "true"
      sudo bash -l -c bundle install "${curdir}/Gemfile"
   # install gems on rvm system path or vendor/bundle
   else
      # if gemdir is the current user dir, install there
      if [ "${conf}" == "/home/${owner}" ]; then
         msg "Performing a local gem install on home dir" "$verbose" "true"
         bundle install
      else
         msg "Performing a local gem install on vendor/bundle" "$verbose" "true"
         bundle install --path vendor/bundle
      fi
   fi
}

# force the production enviroment
export RAILS_ENV=production

config_dir="$1"            # config dir
config_id="$2"             # config id
verbose="$3"               # verbose mode
newline="true"             # default newline on messages
logfile="/tmp/traq$$.log"  # log file

# parse command line options
while getopts "horgksi" OPTION
do
   case ${OPTION} in
      h)
         usage
         exit 1
         ;;
      o)
         echo "Gem dir owner is: $(gemdir_owner)"
         exit 1
         ;;
      r)
         echo "RVM gem dir owner is: $(rvm_owner)"
         exit 1
         ;;
      g)
         echo "Gem dir owner is: $(gem_owner)"
         exit 1
         ;;
      k)
         echo "Gemfile checksum is: $(gemfile_checksum)"
         exit 1
         ;;
   esac
done

msg "Log file is ${logfile}" "${verbose}" "true"

# move to the correct directory
dir="${1}"
cd_app_dir "${dir}"
safe_copy "${config_id}"

# check Gemfile checksum
old_gemfile_md5=$(gemfile_checksum)
install_new_files "${config_id}"
new_gemfile_md5=$(gemfile_checksum)

# if the current Gemfile is different, run bundle install
if [ -f Gemfile -a "$old_gemfile_md5" != "$new_gemfile_md5" ]; then
   fix_gems
fi

migrate
assets
permissions

# restart server
if [ -x ./traq/server.sh -a -f ./traq/server.sh ]; then
   ./traq/server.sh
fi

# extra configs
if [ -x ./traq/extra.sh -a -f ./traq/extra.sh ]; then
   ./traq/extra.sh
fi

# erase file
rm traq/${config_id}.zip
