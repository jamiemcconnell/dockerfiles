# Base our container on an existing Docker Image, view its configuration here: http://bit.ly/2h7SHaO
FROM httpd:2.4.18
MAINTAINER Jamie McConnell <jamie_mcconnell@icloud.com>

# This is a directory that you can "mount" your code into
VOLUME /var/www/html

# We need to expose a port on the container for us to view whatever Apache is hosting for us
EXPOSE 80

# This should look pretty self-explanatory, install the packages you want on the apache/php box.
RUN apt-get update -qy
RUN apt-get install -qy php5 libapache2-mod-php5 php5-mysql php5-mcrypt php5-curl curl php5-mcrypt php5-gd php-pear php-apc php5-imagick imagemagick

# Enable some Apache modules.
RUN a2enmod rewrite
RUN a2enmod headers
# Hack to make eboraas/apache-php work
RUN a2enmod socache_shmcb

# Hack to fix permissions of www-data user: https://github.com/boot2docker/boot2docker/issues/587
RUN usermod -u 1000 www-data

# We need to copy in our virtual hosts configuration file so Apache has something to serve
COPY virtualhosts.conf /etc/apache2/sites-enabled/virtualhosts.conf

# Delete the default config files - we dont need them.
RUN rm -f /etc/apache2/sites-enabled/001-default-ssl
RUN rm -f /etc/apache2/sites-enabled/000-default.conf

# You may want to do some configuration on startup of your container eg: setting permissions on some folders.
# I am using an entrypoint.sh file which will run when this container is started.
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Tell Docker to run this file when the container starts.
ENTRYPOINT ["/entrypoint.sh"]
