CREATE TABLE moscow_boundary AS
SELECT way FROM planet_osm_polygon
WHERE boundary IS NOT NULL AND admin_level='5';

DELETE FROM boundary
WHERE name='Новомосковский административный округ';

CREATE TABLE moscow_buildings AS
SELECT osm_id,way,"addr:housenumber" as housenum,name,landuse,amenity,building,construction FROM planet_osm_polygon
WHERE (building IS NOT NULL OR construction IS NOT NULL) AND osm_id IN
(SELECT DISTINCT planet_osm_polygon.osm_id FROM planet_osm_polygon
INNER JOIN boundary
ON ST_Intersects(boundary.way,planet_osm_polygon.way));

CREATE TABLE moscow_roads AS
SELECT osm_id,highway,name,way FROM planet_osm_line
WHERE highway IS NOT NULL AND name IS NOT NULL AND railway IS NULL AND place IS NULL AND boundary IS NULL AND osm_id IN
(SELECT DISTINCT planet_osm_line.osm_id FROM planet_osm_line
INNER JOIN boundary
ON ST_Intersects(boundary.way,planet_osm_line.way));

CREATE TABLE moscow_water AS
SELECT osm_id,name,way FROM planet_osm_polygon
WHERE water IS NOT NULL AND osm_id IN
(SELECT DISTINCT planet_osm_polygon.osm_id FROM planet_osm_polygon
INNER JOIN boundary
ON ST_Intersects(boundary.way,planet_osm_polygon.way));

CREATE TABLE moscow_rivers AS
SELECT osm_id,name,way FROM planet_osm_line
WHERE waterway IS NOT NULL AND name IS NOT NULL AND osm_id IN
(SELECT DISTINCT planet_osm_line.osm_id FROM planet_osm_line
INNER JOIN boundary
ON ST_Intersects(boundary.way,planet_osm_line.way));

CREATE TABLE moscow_green AS
SELECT osm_id,name,way FROM planet_osm_polygon 
WHERE (landuse='meadow' OR landuse='grass' OR landuse='forest' OR landuse='park' OR landuse='greenfield' or leisure is not null) AND osm_id IN
(SELECT DISTINCT planet_osm_polygon.osm_id FROM planet_osm_polygon
INNER JOIN boundary
ON ST_Intersects(boundary.way,planet_osm_polygon.way));


