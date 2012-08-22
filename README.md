# Traquitana

This project is a collection of scripts I used before met Capistrano and the
other tools to do that.
It send some files from your local Rails app directory to a production remote
server, using some
default libs on Ruby like net/ssh and net/scp, and rubyzip to zip all the files
and try to make
things faster.

It was made to run on GNU/Linux, but should work on similar systems. 

## Installation

Add this line to your application's Gemfile:

    gem 'traquitana'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install traquitana

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

	On the list can have two elements by row, like:

   - - public/images/**/*
     - public/images/uploads/**/*

	On this example, all below public/images will be send BUT ignoring what is on public/images/uploads. This is a way to
	make sure you'll not overwrite some production files with your development versions.

- PLEASE PLEASE PLEASE configure this file. You can create an app on your localhost and 
make some tests on it 'till you think is safe deal with real apps on production servers.
- Run traq (just type traq). 
	- It will search for changed files
	- Will create a list with the file names found
	- Will zíp the files.
	- Will send the list to the server, together with some control files.
		- What the control files deal: they are shell scripts that will zip the old files (based on what new files are going),
		unzip the new files, run migrations if needed and restart the web server. There are two files: one generic to make all
		sort of things BUT not restarting the web server. The webserver script will be send based on what webserver you need.
- Now everything should be updated. On the next time you want to update your project, just run traq again.

* The list and the zip file created with the old files will be used on future versions as a rollback feature.	

Use for your risk. I think it's all ok but I don't give you guarantee if it break something.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
