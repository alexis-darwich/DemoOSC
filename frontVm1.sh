#! /bin/bash
dest="/var/www/html/index.html"
apt-get update -y
apt-get install -y lighttpd
echo "<html><body style=\"background-color:red;color:white;text-align:center;font-size:80px;\">Node 1</body></html>" > $dest
chmod a+r $dest