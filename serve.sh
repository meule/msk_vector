cp nginx-moscow.conf /etc/nginx/sites-enabled/moscow
cp index.html /etc/nginx/sites-enabled/moscow
gunicorn -c gunicorn.cfg.py -p /tmp/gunicorn.pid 'TileStache:WSGITileServer("tilestache.cfg")'
sudo service nginx restart