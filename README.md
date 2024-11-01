[![Downloads](https://img.shields.io/gem/dt/traquitana.svg)](https://rubygems.org/gems/traquitana)
[![Version](https://img.shields.io/gem/v/traquitana.svg)](https://rubygems.org/gems/traquitana)
[![License](https://img.shields.io/badge/license-GPLV2-brightgreen.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html)

# Traquitana

This project is a collection of scripts I used before met Capistrano and the
other tools to do that.  It send some files from your local Rails app directory
to a production remote server, using some default libs on Ruby like net/ssh and
net/scp, and rubyzip to zip all the files and try to make things faster.

It was made to run on GNU/Linux, but should work on similar systems. 

## Installation

Add this line to your application's Gemfile:

```
gem 'traquitana'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install traquitana
```

## Usage

- Go to your Rails app directory.
- Run traq setup.
- Now you have a traq.yml file on the config dir. Open It.
- There are simple configurations there:
	- host: where your production server is, for example, myhost.com
	- user: user name to connect to the server (SSH)
	- password: user password (SSH), can be blank if you use connect with no password to the server
	- directory: where your app is on the server. please use the full path based on where the login occurs! ex: /home/user/myapp/
	- ignore: it will just send the files that had changed on less than the number of hours configured here
	- server: the webserver running on the server. ex: passenger
	- list: the list of file patterns searched to send to the server
    - branches: optional, will check if your Git current branch is allowed on
      the branches listed here (comma separated), preventing from deploying from
      a wrong branch

	On the list can have two elements by row, like:

```
- - public/images/**/*
  - public/images/uploads/**/*
```

   On this example, all below public/images will be send BUT ignoring what is on
   public/images/uploads. This is a way to make sure you'll not overwrite some
   production files with your development versions.

- PLEASE PLEASE PLEASE configure this file. You can create an app on your
  localhost and make some tests on it 'till you think is safe deal with real
  apps on production servers.

  Also, if you want multiple targets, you can use the names you want, just
  "default" is reserved on a multiple targets file, to use when you don't
  specify any tags. Take a look on the custom.yml file provided and use
  -t or --target <target>.

- Run traq (just type `traq`). 
	- It will search for changed files
	- Will create a list with the file names found
	- Will zíp the files.
	- Will send the list to the server, together with some control files.
    - What the control files are for: they are shell scripts that will zip the
      old files (based on what new files are going), unzip the new files, run
      migrations if needed, run bundle install if the Gemfile contents changed
      and restart the web server. There are two files: one generic to make all
      sort of things BUT not restarting the web server. The webserver script will
      be send based on what webserver you need.

- Now everything should be updated. On the next time you want to update your
  project, just run traq again.

* The list and the zip file created with the old files will be used on future
  versions as a rollback feature.	

Use for your risk. I think it's all ok but I don't give you guarantee if it
break something.

## CLI options

There are some command line options:

* `-f` or `--file <file>` - specify the config file path
* `-v` or `--version` - show current version
* `-c` or `--cleanup` - clean old versions backups stored on the remote host
* `-v` or `--verbose` - be verbose while running
* `-t` or `--target <target>` - specify which target will be loaded on the config file

## Drawbacks

As we're sending the local files to the server, if you deleted some file from
your local repository, **it will not be deleted from your server**, so, you'll
need to take care of this by yourself. I was inclined to check for the deleted
files on the file list sent to the server, comparing with the local files there,
and then delete the files, but I think file deletion could be a little more
invasive than I'd would like about how this gem works. Maybe on future I can
change my mind.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Test it! Run `$ rake test`. You'll need `minitest` and `minitest-focus`.
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
