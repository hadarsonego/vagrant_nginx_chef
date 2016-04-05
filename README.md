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

My repo
---

You don't have to create manually the folders and files although i expain how to do it, you can just clone my repo to the folder that you want the vagrant to work from.


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

1. Create a folder tree called cookbooks/nginx/ or just clone my repo to the folder that you want (inside the same directory as the vagrantfile).

2. Inside the nginx directory create 2 directories named "files" & "recipes".

  A. files directory - Will contain all the files that chef will sync with your machine (HTML's & conf files in our case)

  B. recipes directory - Will contain the recipe (set of instruction that the chef will do at chef run) for your machine in our case it called default.rb

Nginx
---
You don't need to do anything manually for the nginx the Chef-solo will take care of editing the relevant files for the it 
(You can edit the HTML files as you like)

**The configuration file and how i used it**

**nginx.conf**

This is the main configuration file of the nginx, you can edit the "default" file under the directory "site-available" as well but i rather do all the configuration centralize via only one file and not 2.
If you like to do this like me you will need to edit the "default" file under the directory "site-available" and comment all the line for them not to be read by the service, if you won't do this your nginx will return error that you have conflict between the files (my repo do the comment of all files in default automatically).

**Important note about the Nginx conf file**

I used the attribute function of the chef solo with template and created all the file with attribute that there value is inside the "attributes" directory , feel free to cahnge it as you like.

For example - 
I use The `default['nginx']['allowip1'] = '10.0.1.1'` attribute to manage access to the admin console, on the ngin conf template it will look like this - `<%= node['nginx']['allowip1'] %>;` the value of this piece of code is simplly `'10.0.1.1'` , this way i manage the nginx.conf more smartlly and store all the important values in one place.

**What i configured**

**all under the http section**

```
http {

    }
```

**The upstream module**

This is a way of declare upsteam servers that you can use these declarations to proxy in more easy way, it scale good as well.

```
upstream backend {
                server localhost:8080;
    
        }
```

**The first nginx site**

1. Create a server that listen to port 80 http

2. tell the Nginx where to find the relevant files for the website

3. Proxy all traffic from this server to the `http://localhost:8080` server

4. Proxy all request for `/admin/login/superuser/` to `http://localhost:8080/admin/login/superuser/` , Block/Allow traffic to it(I allowed 10.0.1.1 for testing if you like to block yourself don't allow your ip) & forward all the 403 errors to another location that will return 401 instead. 

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
                proxy_pass http://backend;
                try_files $uri $uri/ =404;
                # Uncomment to enable naxsi on this location
                # include /etc/nginx/naxsi.rules
        }
        location  /admin/login/superuser/ {
                proxy_pass http://backend/<%= node['nginx']['adminproxy'] %>/;
                allow <%= node['nginx']['allowip1'] %>;
                allow <%= node['nginx']['allowip2'] %>;
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

        root <%= node['nginx']['rootlocation'] %>;
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

        }
   
```

**The Gzip compression**

Simple configuration that make this nginx compress the content with gzip, the on/off can be change in the chef attributes.

```
##
# Gzip Settings
##

gzip <%= node['nginx']['gzipswitch'] %>;
```

**Where to log**

I was asked to create my own location for access logs, by default nginx will store them under `/var/log/nginx/` i forced it to write the access logs to the `/var/log/nginx/hadarlog/` directory you can see that in the chef attribute file.

```
##
# Logging Settings
##
        
access_log <%= node['nginx']['customlogdir'] %>;
error_log /var/log/nginx/error.log;
```

#How the whole thing work?!

#**Let's start explaining**

The vagrant will start a machine as we like by reading the relevant vagrantfile that will be at the directory which we run vagrant from.

My vagrantfile installs the ubuntu/trusty64 vagrant box then name it to Ubuntu 14.04 , set the ip to 10.0.1.59 (you can use any ip that you like, take notice that it needs to be on the same subnet as your interface in Virtualbox, my interface is 10.0.1.1/24 so any ip from 10.0.1.2 to 10.0.1.x will be good) and set the provision to Chef and tell it to run the Nginx cookbook.

As the machine comes up the chef starts kicking by running the recipe that related to the cookbook.

The chef will then read the recipe that contains the instruction for what to do.

1. Read all the cookbooks in the cookbooks directory, one of them is the Nginx cookbook i downloaded from the chef website.

2. The nginx will be installed when it's recipe will start.

2. Create all the relevant directories inside the Nginx directories.

3. Create the nginx.conf with the template in the "main" cookbook and place it in the `/etc/nginx/` directory
 
4. Sync all relevant files from the "files" directory under the cookbook at our local machine  (these are all the nginx costume HTML's and the site-available config file).

4. Restart the Nginx service for it to load all the new conf files and HTML's.


**Ok i got it now how do i make this whole operation up and running??**
---

When you are ready and all the files are in place (The directory with the vagrant file on your computer) you need to do the simplest thing, just run from the command line (from the vagrantfile location) `vagrant up` , it will take some time because the vagrant need to download the relevant box and then install it, when it's done you can try go to your website via the IP you gave to the machine.

**Important notes**
---

1. Don't forget to change the ip on the vagrant file i uploaded to the same subnet as your virtualbox interface 

2. Feel free to edit the HTML files as you like , but remember you need to edit them on your computer and not on the virtualbox machine , if you will do it on the VirtualBox machine the whole thing will be deleted the moment you will run Chef because the recipe tell Chef to take the files from your computer and replace the one's on the machine with them.
To make the changes work just run `vagrant --provision` , this will make the chef run and do what he knows to do.


