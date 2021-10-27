--4.	Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty) 
--położonych w odległości mniejszej niż 1000 m od głównych rzek. Budynki spełniające to kryterium zapisz do osobnej tabeli tableB.
SELECT COUNT(popp.gid) from popp,majrivers WHERE popp.f_codedesc LIKE 'Building' AND ST_Distance(popp.geom,majrivers.geom)<1000;

SELECT popp.* INTO TableB from popp,majrivers WHERE popp.f_codedesc LIKE 'Building' AND ST_Distance(popp.geom,majrivers.geom)<1000;
SELECT * from Tableb;

--5.	Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.  

SELECT name,elev,geom INTO airportsNew from airports;

--a) Znajdź lotnisko, które położone jest najbardziej na zachód 

SELECT name,ST_AsText(geom) from airportsNew ORDER BY ST_X(geom) ASC LIMIT 1;

--i najbardziej na wschód. 

SELECT name,ST_AsText(geom) from airportsNew ORDER BY ST_X(geom) DESC LIMIT 1;

--b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. 
--Lotnisko nazwij airportB. Wysokość n.p.m. przyjmij dowolną.
--Uwaga: geodezyjny układ współrzędnych prostokątnych płaskich (x – oś pionowa, y – oś pozioma)

INSERT INTO airportsNew(name,elev,geom) VALUES
('airportB',0,(SELECT ST_Centroid(ST_MakeLine((SELECT geom from airportsNew WHERE name LIKE 'ATKA'),
											  (SELECT geom from airportsNew WHERE name LIKE 'ANNETTE ISLAND')))));
--6.	Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”

SELECT ST_Area(ST_Buffer(ST_ShortestLine(lakes.geom,airportsNew.geom),1000)) 
from lakes,airportsNew WHERE lakes.names LIKE 'Iliamna Lake' AND airportsNew.name LIKE 'AMBLER';

--7.	Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps).  

SELECT SUM(ST_Area(trees.geom)),trees.vegdesc from trees,tundra,swamp WHERE ST_Contains(tundra.geom,trees.geom) OR ST_Contains(swamp.geom,trees.geom) 
GROUP BY trees.vegdesc


