--3.
CREATE EXTENSION postgis; 

--4.
CREATE TABLE buildings(id int primary key, geometry geometry, name varchar(25));
CREATE TABLE poi(id int primary key, geometry geometry, name varchar(25));
CREATE TABLE roads(id int primary key, geometry geometry, name varchar(25));

--5.
INSERT INTO buildings(id, geometry, name )
VALUES(1,'POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5,8 4))','BuildingA'),
(2,'POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))','BuildingB'),
(3,'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))','BuildingC'),
(4,'POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))','BuildingD'),
(5,'POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))','BuildingF')

INSERT INTO poi(id, geometry, name )
VALUES(1,'POINT(1 3.5)','G'),
(2,'POINT(5.5 1.5)','H'),
(3,'POINT(9.5 6)','I'),
(4,'POINT(6.5 6)','J'),
(5,'POINT(6 9.5)','K')

INSERT INTO roads(id, geometry, name )
VALUES(1,'LINESTRING(0 4.5,12 4.5)','RoadX'),
(2,'LINESTRING(7.5 10.5, 7.5 0)','RoadY')

--6.
--a)
SELECT  sum(ST_Length(geometry)) AS total_roads_length FROM roads
--b)
SELECT ST_AsText(geometry),ST_Area(geometry),ST_Perimeter(geometry) FROM buildings WHERE name LIKE 'BuildingA'
--c)
SELECT name, ST_Area(geometry) AS Area FROM buildings ORDER BY name
--d)
SELECT name, ST_Perimeter(geometry) AS Perimeter FROM buildings ORDER BY Perimeter DESC LIMIT 2
--e)
SELECT ST_Distance(buildings.geometry, poi.geometry) FROM buildings, poi WHERE buildings.name LIKE 'BuildingC' AND poi.name LIKE 'G'
--f)
SELECT ST_Area(ST_Difference((SELECT geometry FROM buildings WHERE name LIKE 'BuildingC'), ST_Buffer(geometry, 0.5))) FROM buildings WHERE name LIKE 'BuildingB'
--g)
SELECT buildings.name AS centroid FROM buildings, roads WHERE roads.name LIKE 'RoadX' AND ST_Y(ST_Centroid(buildings.geometry))>ST_Y(ST_Centroid(roads.geometry))
--SELECT name,ST_ASText(ST_Centroid(geometry)) FROM buildings 	
--h)
SELECT ST_Area(ST_SymDifference(geometry,'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')) FROM buildings WHERE name LIKE 'BuildingC'



			   
			   