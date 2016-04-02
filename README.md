# Jacada project - vagrant_nginx_chef
Vagrant environment over virtualbox to auto install Nginx and provision it with Chef-solo

#The main goals

1. Create Nginx web server that will serve content behind another Nginx server that will act as proxy server

2. Block and allow specific IP addresses to certain URL's  

3. Make this all process working by easily create the instance and make it up and running 

4. Make this all solution manageable by working with configuration managment tool



Let me give you a quick brief about the tools we use
---

**We use 4 main tools for this solution**  

**Vagrant**

The tool that will create the specific machine that we want and will give us the option to select basic settings like IP and provision tool


**VirtualBox**

The host for our virtual machine (You can use anything from VMWare to AWS)


**Chef-solo**

The provision tool that will help us to control our machine and deploy changes in configuration if we like, this is why you can hear the name "configuration managment tool" for Chef.


**Nginx**

The web server that will be used in our solution for this purpose and all-so will be used as our proxy (You will get it soon) 


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


2. After installation open your command line and navigate to the directory that you created.

3. Run the command  `vagrant init` that will create a vagrantfile.

4. You can take the vagrantfile that i uploaded to this repo (if so skip instruction 3) or just copy the content to your vagrantfile you just created.
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

  B. recipes diractory - Will contain the recipe (set of instruction that the chef will do at chef run) for your machine in our case it called default.rb

Nginx
---
You don't need to do anything manualy for the nginx the Chef-solo will take care of editing the relevant files for the it 
(You can edit the HTML files as you like)

**The configuration file and how i used it**

**nginx.conf**

This is the main configuration file of the nginx, you can edit the "default" file under the directory "site-available" as well but i rether do all the configuratin centralize via only one file and not 2.
If you like to do this like me you will need to edit the "default" file under the directory "site-available" and commant all the line for them not to be read by the service, if you won't do this your nginx will return error that you have conflict between the files.

**What i configured**

**all uder the http section**

```
http {

    }
```

**The first nginx site**

1. Create a server that listen to port 80 http

2. tell the Nginx where to find the relevant files for the website

3. Proxy all traffic from this server to the `http://localhost:8080` server

4. Proxy all request for `/admin/login/superuser/` to `http://localhost:8080/admin/login/superuser/` , Block/Allow traffic to it & forward all the 403 errors to another location that will return 401 insted. 

``` 
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        root /usr/share/nginx/html;
        index index.html index.htm;
                # Make site accessible from http://localhost/
        server_name localhost;
        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                proxy_pass http://localhost:8080;
                try_files $uri $uri/ =404;
                # Uncomment to enable naxsi on this location
                # include /etc/nginx/naxsi.rules
        }
        location  /admin/login/superuser/ {
                proxy_pass http://localhost:8080/admin/login/superuser/;
                allow 10.0.1.1;
                allow 212.199.129.1;
                deny all;
                error_page 403 = @unauthorized;
        }
        location @unauthorized {
                return 401;
        }
        }
```  

**The second nginx site**

1. Create a server that listen to port 8080 http

2. tell the Nginx where to find the relevant files for the website (The Admin console this time).

```
        server {

        listen 8080 default_server;
        listen [::]:8080 default_server ipv6only=on;

        root /usr/share/nginx/newhtml;
        index index.html index.htm admin.html;

        # Make site accessible from http://localhost/
        server_name localhost;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
                # Uncomment to enable naxsi on this location
                # include /etc/nginx/naxsi.rules
                }

        
```

**The Gzip compression**

Simple configuration that make this nginx compress the content with gzip.

```
##
# Gzip Settings
##

gzip on;
gzip_disable "msie6";
```

**Where to log**

I was asked to create my own location for access logs, by default nginx vill store them under `/var/log/nginx/` i forced it to write the access logs to the `/var/log/nginx/hadarlog/` directory.

```
##
# Logging Settings
##
        
access_log /var/log/nginx/hadarlog/access.log;
error_log /var/log/nginx/error.log;
```

#How the whole thing work?!

#**Let's start explaining**

The vagrant will start a machin as we like by reading the relevant vagrantfile that will be at the directory which we run vagrant from.

My vagrantfile installs the ubuntu/trusty64 vagrant box then name it to Ubuntu 14.04 , set the ip to 10.0.1.59 (you can use any ip that you like, take notice that it needs to be on the same subnet as your interface in Virtualbox, my interface is 10.0.1.1/24 so any ip from 10.0.1.2 to 10.0.1.x will be good) and set the provision to Chef and tell it to run the Nginx cookbook.

As the machine comes up the chef starts kicking by running the recipe that related to the cookbook.

The chef will then read the recipe that contains the instruction for what to do.

1. Install the nginx package via machine package manager.

2. Create all the relevant directories inside the Nginx directories.

3. Sync all relevant files from the "files" directory under the cookbook at our local machine  (these are all the nginx costume HTML's and config files).

4. Restart the Nginx service for it to load all the new conf files and HTML's.


**Ok i got it now how do i make this whole operation up and running??**
---

When you are ready and all the files are in place (The diractory with the vagrant file on your computer) you need to do the simplest thing, just run from the command line (from the vagrantfile location) `vagrant up` , it will take some time because the vagrant need to download the relevant box and then install it, when it's done you can try go to your website via the IP you gave to the machine.

**Important notes**
---

1. Dont forgat to change the ip on the vagrant file i uploaded to the same subnet as your virtualbox interface 

2. Feel free to edit the HTML files as you like , but remember you need to edit them on your computer and not on the virtualbox machine , if you will do it on the VirtualBox machine the whole thing will be deleted the moment you will run Chef because the recipe tell Chef to take the files fron your computer and replace the one's on the machine with them.
To make the changes work just run `vagrant --provision` , this will make the chef run and do what he knows to do.


