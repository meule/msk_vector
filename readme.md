Vector tiles map server for Moscow buildings

Tilestache + Gunicorn + nginx + Amazon EC2 Ubuntu + Amazon RDS Postgres

2do

	server
		WKB (with MVT?): http://blog.jordogskog.no/tag/twkb/ http://blog.jordogskog.no/2013/04/29/more-twkb/ 
		Tilestache: Memcache and S3: http://tilestache.org/doc/
		nginx config: http://www.itopen.it/2012/01/17/serving-your-map-tiles-30-times-faster/
		simplyfy
			http://hanskuder.com/code/building-interactive-maps-polymaps-tilestache-mongodb/
			склеить geometry by year where zoom<13
			склеить все geometry by basic layer (roads, water, etc) where zoom<13
		topojson

	client
		topojson
		slider

	data
		max join