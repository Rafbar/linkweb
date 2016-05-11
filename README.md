### LINUX Deploy (Tested with Ubuntu 12.04 LTE)

### Environment setup:

Basic apts:

> sudo apt-get update
> sudo apt-get install curl vim git

RVM (rvm.io):

> gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
> \curl -sSL https://get.rvm.io | bash -s stable

# Remember to add this line to .bashrc if you don't want to write it each time you run the VM
> source ~/.rvm/scripts/rvm

> rvm install 2.2
> rvm use 2.2 --default


### Apt dependencies

Required for headless:

> sudo apt-get install xvfb

Required for capybara-webkit:

> sudo apt-get install python-software-properties
> sudo apt-add-repository ppa:ubuntu-sdk-team/ppa
> sudo apt-get update


### Gem dependencies

Required for bundler

> gem install bundler
> bundle install



### Running the spider
> ruby linkweb.rb
> Linkweb.test(URL)