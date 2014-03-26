git pull
cp -R nginx-moscow.conf /etc/nginx/sites-enabled/moscow
cp -R index.html /etc/nginx/sites-enabled/moscow
cp -R topo.html /etc/nginx/sites-enabled/moscow
sudo service nginx restart
kill `cat /tmp/gunicorn.pid`
gunicorn -c gunicorn.cfg.py -p /tmp/gunicorn.pid 'TileStache:WSGITileServer("tilestache.cfg")' &