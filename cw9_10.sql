SELECT ST_Srid(geom) from public."Exports"

CREATE TABLE dummy_rast(rid int, rast raster)
INSERT INTO dummy_rast(rid,rast)
VALUES(3, ST_MakeEmptyRaster( 100, 100, 0.0005, 0.0005, 1, 1, 0, 0, 4326) );

DROP TABLE if exists public.result;
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.objectid,-32767)) INTO public.result from public."Exports" a, public.dummy_rast r


