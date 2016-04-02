# Jacada project - vagrant_nginx_chef
Vagrant environment over virtualbox to auto install Nginx and provision it with Chef-solo

#How the whole thing work?!

Let me explain before we starting the step by step
---

**We use 4 main tools for this solution**  

**Vagrant**

The tool that will create the specific machine that we want and will give us the option to select basic settings like IP and provision tool


**VirtualBox**

The host for our virtual machine (You can use anything from VMWare to AWS)


**Chef-solo**

The provision tol that will help us to control our machine and deploy changes in configuration if we like, this is why you can hear the name "configuration managment tool" for Chef.


**Nginx**

The web server that will be used in our solution for this purpose and all-so will be used as our proxy (You will get it soon) 

**Let's start explaining -**

The vagrant will start a machin as we like by reading the relevant vagrantfile that will be at the directory which we run vagrant from.

My vagrantfile installs the ubuntu/trusty64 vagrant box then name it to Ubuntu 14.04 , set the ip to 10.0.1.59 (you can use any ip that you like, take notice that it needs to be on the same subnet as your interface in Virtualbox, my interface is 10.0.1.1/24 so any ip from 10.0.1.2 to 10.0.1.x will be good) and set the provision to Chef and tell it to run the Nginx cookbook.

As the machine comes up the chef starts kicking by running the recipe that related to the cookbook.

The chef will then read the recipe that contains the instruction for what to do.

1. Install the nginx package via machine package manager.

2. Create all the relevant directories inside the Nginx directories.

3. Sync all relevant files from the "files" directory under the cookbook at our local machine  (these are all the nginx costume HTML's and config files).

4. Restart the Nginx service for it to load all the new conf files and HTML's.


#instructions
----

Downloads & Install
---

1. Download Vagrant tool from Vagrant website - https://www.vagrantup.com/

2. Download Virtualbox tool from Virtualbox website - https://www.virtualbox.org/wiki/Downloads


#Getting ready


Vagrant
---

1. Create directory with any name that you want with read and execute privilege to all users.


2. After installtion open your command line and navigate to the diractiory that you created.

3. Run the command  `vagrant init` that will create a vagrantfile.

4. You can take the vagrantfile that i uploaded to this repo (if so skip instruction 3) or just copy the contant to your vagrantfile you just created.
**(You can take all the directory i uploaded to this repo and past it there if you don't want to create them manually, it contains all the chef directories and nginx necessary files, i will talk about it in the chef section)**

Vagrant Box's
---

Vagrant box is a pri-configured virtual box instance that you can download from these websites for your need.
In our case we used "ubuntu/trusty64" that has already chef & ruby installed and i downloaded it from the first website.

A. https://atlas.hashicorp.com/boxes/search

B. http://www.vagrantbox.es/

You can see that in the vagrantfile i tell the vagrant to use this box (ubuntu/trusty64) in these lines. 
(these lines of code will all so go and download the box automatically). 

```
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
end
```


chef-solo
---

1. Create a folder tree called cookbooks/nginx/ (inside the same diractiory as the vagrantfile).

2. Inside the nginx diractiory create 2 diractories named "files" & "recipes".

  A. files directiory - Will contain all the files that chef will sync with your machine (HTML's & conf files in our case)

  B. recipes diractory - Will contain the recipe (set of instruction that the chef will do at chef run) for your machine in our case it   called default.rb
  
