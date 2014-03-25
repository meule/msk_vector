ALTER TABLE data
ADD COLUMN housenum_data varchar;

UPDATE data
SET housenum_data=upper(regexp_replace(address,'.*, (.*)','\1'))
WHERE address IS NOT NULL;



CREATE TABLE housenums AS
SELECT address,regexp_replace(address,'.*, (.*)','$1') as housenum_data FROM data
WHERE address IS NOT NULL;


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

CREATE TABLE bd_st_Dwithin5 AS
SELECT moscow_buildings.osm_id,data.address,moscow_buildings.housenum
FROM moscow_buildings
INNER JOIN data ON ST_DWithin(data.geom4, moscow_buildings.way,5);

-- researching

ALTER TABLE bd_st_Dwithin5
ADD COLUMN housenum_osm varchar;
ALTER TABLE bd_st_Dwithin5
ADD COLUMN housenum_data varchar;

UPDATE bd_st_Dwithin5
SET housenum_osm=upper(regexp_replace(housenum,' ',''))
WHERE housenum IS NOT NULL;

UPDATE bd_st_Dwithin5
SET housenum_data=upper(regexp_replace(address,'.*, (.*)','\1'))
WHERE address IS NOT NULL;

CREATE TABLE dwithin5_samehousenum AS
SELECT bd_st_Dwithin5.osm_id,bd_st_Dwithin5.address,bd_st_Dwithin5.housenum FROM dwithin1_samehousenum
INNER JOIN bd_st_Dwithin5 as bd2
ON bd_st_Dwithin5.housenum_data=bd2.housenum_osm
WHERE bd_st_Dwithin5.address!=bd2.address and bd_st_Dwithin5.osm_id=bd2.osm_id;

create table data_with_distance3 as
select data.geom4 from data
inner join data as data2
on ST_Distance(data.geom4,data2.geom4)<3
where data.address!=data2.address;

create table data_with_distance3_plus_address_year as
select  data_with_distance3_plus_address.geom4,data_with_distance3_plus_address.address,data.year from data_with_distance3_plus_address
inner join data
on data_with_distance3_plus_address.geom4=data.geom4;


create table data_same  as
select  data_with_distance3_plus_address_year.geom4,data.geom4 as geom4_neightboor from data_with_distance3_plus_address_year
inner join data
on data_with_distance3_plus_address_year.geom4=data.geom4
where data.year=data_with_distance3_plus_address_year.year;

select *,(housenum_osm=housenum_data) as bool from dwithin1_samehousenum where housenum is not null;



create table msk as select ogc_fid,address,year,ST_Transform(ST_SetSRID(wkb_geometry),900913) from ogrgeojson;

create table msk_grouped as SELECT bd.year, ST_Union(bd.geom) as geom FROM msk As bd GROUP BY bd.year;

CREATE TABLE msk_grouped2 AS SELECT msk.year,ST_Union(ST_SnapToGrid(msk.geom,0.0001)) as geom FROM msk GROUP BY msk.year;

-- end researching

