#! /bin/bash
dest="/var/www/html/index.html"
apt-get update -y
apt-get install -y lighttpd
# sudo chmod -R 777 /var/www/html/ (si en mode ligne de commande avec user outscale)
echo "<html><body style=\"background-color:blue;color:white;text-align:center;font-size:80px;\">Node 2</body></html>" > $dest
chmod a+r $dest