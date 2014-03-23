#config: https://www.digitalocean.com/community/articles/how-to-deploy-python-wsgi-apps-using-gunicorn-http-server-behind-nginx      http://gunicorn-docs.readthedocs.org/en/latest/deploy.html    http://mattmakesmaps.com/blog/2013/10/09/tilestache-rendering-topojson/

#PostGIS scripts http://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS20Ubuntu1204
sudo pip install django TileStache ModestMaps Werkzeug vectorformats
sudo apt-get install build-essential postgresql-9.1 postgresql-server-dev-9.1 libxml2-dev proj libjson0-dev xsltproc docbook-xsl docbook-mathml gettext postgresql-contrib-9.1 pgadmin3
sudo apt-get install python-software-properties
sudo apt-add-repository ppa:olivier-berten/geo
sudo apt-get update
sudo apt-get install libgdal-dev
sudo apt-get install g++ ruby ruby1.8-dev swig swig2.0   ''--- added to other instructions, not installed by default in 12.04 & required for this make
wget http://download.osgeo.org/geos/geos-3.3.3.tar.bz2
tar xvfj geos-3.3.3.tar.bz2
cd geos-3.3.3
./configure --enable-ruby --prefix=/usr
make
sudo make install
cd ..
wget http://postgis.refractions.net/download/postgis-2.0.0.tar.gz
tar xfvz postgis-2.0.0.tar.gz
cd postgis-2.0.0
./configure --with-gui     <--- not sure if the with-gui is required
make
sudo make install
sudo ldconfig
sudo make comments-install
sudo ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/shp2pgsql
sudo ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/pgsql2shp
sudo ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/raster2pgsql

sudo vi /etc/postgresql/9.1/main/pg_hba.conf
#Add the line "local all all trust" to pg_hba.conf
sudo service postgresql restart

#PostGIS get started http://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS20Ubuntu1204
sudo -u postgres createdb template_postgis
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/postgis.sql
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/spatial_ref_sys.sql
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/postgis_comments.sql
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/rtpostgis.sql
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/raster_comments.sql
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/topology.sql
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/9.1/contrib/postgis-2.0/topology_comments.sql

#osm2pgsql http://wiki.openstreetmap.org/wiki/Osm2pgsql#From_source
sudo apt-get install build-essential libxml2-dev libgeos++-dev libpq-dev libbz2-dev proj libtool automake git
sudo apt-get install libprotobuf-c0-dev protobuf-c-compiler
sudo apt-get install protobuf-compiler libprotobuf-dev libprotoc-dev subversion
svn checkout http://protobuf-c.googlecode.com/svn/trunk/ protobuf-c-read-only
cd protobuf-c-read-only
./autogen.sh
make
sudo make install
sudo apt-get install lua5.2 liblua5.2-0 liblua5.2-dev liblua5.1-0
git clone https://github.com/openstreetmap/osm2pgsql.git
cd osm2pgsql/
./autogen.sh
./configure
sed -i 's/-g -O2/-O2 -march=native -fomit-frame-pointer/' Makefile
make

#import
curl -O http://osm-metro-extracts.s3.amazonaws.com/moscow.osm.pbf
osm2pgsql -c -G -S /usr/share/osm2pgsql/default.style -U postgres -d osm moscow.osm.pbf

#for amazon rds: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS
#osm2pgsql -c -G -S /usr/share/osm2pgsql/default.style -U postgres -d vectortiles -H vectortiles.cqhmm2t3v2eb.eu-west-1.rds.amazonaws.com -U ubuntu moscow.osm.pbf
#psql -c "CREATE EXTENSION postgis;" -h vectortiles.cqhmm2t3v2eb.eu-west-1.rds.amazonaws.com -d vectortiles -U ubuntu
#psql -c "CREATE EXTENSION fuzzystrmatch;" -h vectortiles.cqhmm2t3v2eb.eu-west-1.rds.amazonaws.com -d vectortiles -U ubuntu
#psql -c "CREATE EXTENSION postgis_tiger_geocoder;" -h vectortiles.cqhmm2t3v2eb.eu-west-1.rds.amazonaws.com -d vectortiles -U ubuntu
#psql -c "CREATE EXTENSION postgis_topology;" -h vectortiles.cqhmm2t3v2eb.eu-west-1.rds.amazonaws.com -d vectortiles -U ubuntu
#psql -c "alter schema tiger owner to rds_superuser;" -h vectortiles.cqhmm2t3v2eb.eu-west-1.rds.amazonaws.com -d vectortiles -U ubuntu
#psql -c "alter schema topology owner to rds_superuser;" -h vectortiles.cqhmm2t3v2eb.eu-west-1.rds.amazonaws.com -d vectortiles -U ubuntu
#


#GeoServer — not needed
sudo apt-get install unzip
sudo apt-get install openjdk-6-jre
sudo apt-get install openjdk-6-jdk
curl -LO http://downloads.sourceforge.net/geoserver/geoserver-2.1.3-bin.zip
unzip geoserver-2.1.3-bin.zip
curl -LO http://downloads.sourceforge.net/geoserver/geoserver-2.1.3-wps-plugin.zip
unzip geoserver-2.1.3-wps-plugin.zip
cd geoserver-2.1.3-bin
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64
bin/startup.sh

#gunicorn
sudo apt-get install python-dev
pip install psycopg2 gunicorn tilestache requests grequests shapely

#nginx
cd /etc/nginx/sites-enabled
sudo mkdir moscow
cd moscow
sudo vi nginx-moscow.conf
#add /etc/nginx/sites-enabled/moscow/*.conf to include section
sudo vi /etc/nginx/nginx.conf
sudo service nginx start
