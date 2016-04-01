# Jacada project - vagrant_nginx_chef
Vagrant environment over virtualbox to auto install Nginx and provision it with Chef-solo

#instructions
----

Downloads & Install
---

1.Download Vagrant tool from Vagrant website - https://www.vagrantup.com/

2.Download Virtualbox tool from Virtualbox website - https://www.virtualbox.org/wiki/Downloads


#Getting ready


Vagrant
---

1.Create diractoty with any name that you want with read and execute privilege to all users.


2.After installtion open your command line and navigate to the diractiory that you created.

3.Run the command  `vagrant init` that will create a vagrantfile.

4.You can take the vagrantfile that i uploaded to this repo (if so skip instruction 3) or just copy the contant to your vagrantfile you just created.
**(You can take all the diractory i uploaded to this repo and past it there if you don't want to create them manually, it contains all the chef diractories and nginx nessesery files, i will talk about it in the chef section)**

Vagrant Box's
---

Vagrant box is a pri-configured virtual box instance that you can download from these websites for your need.
In our case we used "ubuntu/trusty64" that has allready chef & ruby installed and i dowsnloaded it from the first website.

A.https://atlas.hashicorp.com/boxes/search

B.http://www.vagrantbox.es/

You can see that in the vagrantfile i tell the vagrant to use this box (ubuntu/trusty64) in these lines. 
(these lines of code will all so go and download the box automaticlly). 

```
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
end
```


chef-solo
---

1.Create a folder tree called cookbooks/nginx/ (inside the same diractiory as the vagrantfile).

2.Inside the nginx diractiory create 2 diractories named "files" & "recipes".

  A.files diractiory - Will contain all the files that chef will sync with your machine (HTML's & conf files in our case)

  B.recipes diractory - Will contain the recipe (set of instruction that the chef will do at chef run) for your machine in our case it   called default.rb
  
