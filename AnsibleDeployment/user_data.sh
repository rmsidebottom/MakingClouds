#!/bin/bash

sudo apt-get install apache2 php -y

echo "<?php echo \$_SERVER['SERVER_ADDR'] ?>" > /var/www/html/index.php

rm /var/www/html/index.html

sudo service apache2 restart