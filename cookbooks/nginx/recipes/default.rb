package "nginx" #apt-get install nginx -y
#Run Nginx service

#creat the newhtml diractory
directory '/usr/share/nginx/newhtml' do
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end
###
#Creating diractories
###
#creat the Admin console diractory tree
directory '/usr/share/nginx/newhtml/admin' do
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end
#creat the login diractory
directory '/usr/share/nginx/newhtml/admin/login' do
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end
#creat the superuser diractory
directory '/usr/share/nginx/newhtml/admin/login/superuser' do
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end
#creat the hadarlog custom diractory
directory '/var/log/nginx/hadarlog' do
	owner 'root'
	group 'root'
	mode '0755'
	action :create
end
###
#Creating files
###
#create the admin colsole html page
cookbook_file '/usr/share/nginx/newhtml/admin/login/superuser/admin.html' do
	source 'admin.html'
	mode '0644'
end
#replace nginx.conf originl file with our file
cookbook_file '/etc/nginx/nginx.conf' do
	source 'nginx.conf'
	mode '0644'
end
#replace index.html originl file with our file
cookbook_file '/usr/share/nginx/newhtml/index.html' do
	source 'index.html'
	mode '0644'
end
#replace 50x.html originl file with our file
	cookbook_file '/usr/share/nginx/newhtml/50x.html' do
	source '50x.html'
 mode '0644'
end
#replace default file inside nginx site-available with our file
	cookbook_file '/etc/nginx/sites-available/default' do
	source 'default'
 mode '0644'
end

#restart nginx service
service 'nginx' do
  action [ :enable, :restart ]
end