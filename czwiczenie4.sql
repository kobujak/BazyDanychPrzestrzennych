CREATE TABLE obiekty(id int primary key, geom geometry, name varchar(25))

INSERT INTO obiekty
VALUES(1,ST_GeomFromText('MULTICURVE(LINESTRING(0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1), CIRCULARSTRING(3 1, 4 2, 5 1),
						LINESTRING(5 1, 6 1))'),'obiekt1')

--VALUES(1,ST_LineToCurve(ST_GeomFromText('LINESTRING(0 1, 1 1, 2 0, 3 1, 4 2, 5 1, 6 1)')),'obiekt1')

INSERT INTO obiekty
VALUES(2,ST_GeomFromText('POLYGON(COMPOUNDCURVE(LINESTRING(10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2),CIRCULARSTRING(14 2, 12 0, 10 2),
						LINESTRING(10 2, 10 6)), CIRCULARSTRING(11 2, 13 2, 11 2))'),'obiekt2')
	   
--VALUES(2,ST_LineToCurve(ST_GeomFromText('CURVEPOLYGON((10 6, 14 6, 16 4, 14 2, 12 0, 10 2, 10 6),(11 2, 13 2, 11 2))')),'obiekt2')

INSERT INTO obiekty
VALUES(3,ST_GeomFromText('POLYGON((7 15, 10 17, 12 13, 7 15))'),'obiekt3')

INSERT INTO obiekty
VALUES(4,ST_GeomFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)'),'obiekt4')

INSERT INTO obiekty
VALUES(5,ST_GeomFromText('MULTIPOINT(30 30 59, 38 32 234)'),'obiekt5')

INSERT INTO obiekty
VALUES(6,ST_GeomFromText('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2),POINT(4 2))'),'obiekt6')
	   
SELECT name,ST_GeometryType(geom) from obiekty

--1. Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół najkrótszej linii łączącej
--obiekt 3 i 4.

SELECT ST_Area(ST_Buffer(ST_ShortestLine(X1.geom,X2.geom),5)) AS Area FROM obiekty X1, obiekty X2
WHERE X1.name LIKE 'obiekt3' AND X2.name LIKE 'obiekt4'


--2. Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te
--warunki.

UPDATE obiekty SET geom = ST_MakePolygon(ST_AddPoint(geom,ST_StartPoint(geom)))
WHERE obiekty.name LIKE 'obiekt4'


--3. W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4.

INSERT INTO obiekty
VALUES(7,(SELECT ST_Collect(X1.geom,X2.geom) FROM obiekty X1, obiekty X2 WHERE X1.name LIKE 'obiekt3' AND X2.name LIKE 'obiekt4' ),'obiekt 7')


--4. Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów
--nie zawierających łuków.

SELECT SUM(ST_Area(ST_Buffer(geom,5))) AS Area FROM obiekty WHERE ST_HasArc(geom) = false







