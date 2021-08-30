# Clone the repos
git clone git@github.com:FermentAble/server.git ~/
git clone git@github.com:FermentAble/fermentable-fe.git ~/
git clone git@github.com:FermentAble/fermentable.git ~/

# Install postgres
sudo apt-get -y install postgresql lib-pqdev

# Add dev.getfermentable.com to hosts
sudo echo '127.0.0.1 dev.getfermentable.com' >> /etc/hosts

# Increase the number of allowed watchers so nodemon will work
echo fs.inotify.max_user_watches=582222 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
