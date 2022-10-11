-- everything that deprecated since 2.0.0

-- Deprecation in 1.2.3
-- Changed: 2.5.0 use 'internal' stype
CREATE AGGREGATE makeline (
        BASETYPE = geometry,
        SFUNC = pgis_geometry_accum_transfn,
        STYPE = internal,
        FINALFUNC = pgis_geometry_makeline_finalfn
        );

-- Old underscored_names replaced by CamelCase names

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_Shift_Longitude(geometry)
        RETURNS geometry AS
        'SELECT ST_ShiftLongitude($1);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_estimated_extent(text,text,text)
        RETURNS box2d AS
        $$
        -- We use security invoker instead of security definer
        -- to prevent malicious injection of a different same named function
        SELECT ST_EstimatedExtent($1, $2, $3);
        $$
        LANGUAGE 'sql' IMMUTABLE STRICT SECURITY INVOKER;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_estimated_extent(text,text)
        RETURNS box2d AS
        $$
        -- We use security invoker instead of security definer
        -- to prevent malicious injection of a same named different function
        -- that would be run under elevated permissions
        SELECT ST_EstimatedExtent($1, $2);
        $$
        LANGUAGE 'sql' IMMUTABLE STRICT SECURITY INVOKER;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_find_extent(text,text,text)
        RETURNS box2d AS
    'SELECT ST_FindExtent($1,$2,$3);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_find_extent(text,text)
        RETURNS box2d AS
    'SELECT ST_FindExtent($1,$2);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_mem_size(geometry)
        RETURNS integer AS
        'SELECT ST_MemSize($1);'
        LANGUAGE 'sql' IMMUTABLE STRICT SECURITY INVOKER;

-- Availability: 2.0.0
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_3DLength_spheroid(geometry, spheroid)
        RETURNS FLOAT8 AS
        'SELECT ST_LengthSpheroid($1,$2);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_length_spheroid(geometry, spheroid)
        RETURNS FLOAT8 AS
    'SELECT ST_LengthSpheroid($1,$2);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_length2d_spheroid(geometry, spheroid)
        RETURNS FLOAT8 AS
        'SELECT ST_Length2DSpheroid($1,$2);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_distance_spheroid(geom1 geometry, geom2 geometry, spheroid)
        RETURNS FLOAT8 AS
    'SELECT ST_DistanceSpheroid($1,$2,$3);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_point_inside_circle(geometry, float8, float8, float8)
        RETURNS bool AS
        'SELECT ST_PointInsideCircle($1,$2,$3,$4);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_force_2d(geometry)
        RETURNS geometry AS
        'SELECT ST_Force2D($1);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_force_3dz(geometry)
        RETURNS geometry AS
        'SELECT ST_Force3DZ($1);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_force_3dm(geometry)
        RETURNS geometry AS
        'SELECT ST_Force3DM($1);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_force_collection(geometry)
        RETURNS geometry AS
        'SELECT ST_ForceCollection($1);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_force_4d(geometry)
        RETURNS geometry AS
        'SELECT ST_Force4D($1);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_force_3d(geometry)
        RETURNS geometry AS
        'SELECT ST_Force3D($1);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_line_interpolate_point(geometry, float8)
        RETURNS geometry AS
        'SELECT ST_LineInterpolatePoint($1, $2);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_line_substring(geometry, float8, float8)
        RETURNS geometry AS
        'SELECT ST_LineSubstring($1, $2, $3);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.1.0
CREATE OR REPLACE FUNCTION ST_line_locate_point(geom1 geometry, geom2 geometry)
        RETURNS float8 AS
        'SELECT ST_LineLocatePoint($1, $2);'
        LANGUAGE 'sql' IMMUTABLE STRICT;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_Combine_BBox(box3d, geometry)
        RETURNS box3d AS
        'SELECT ST_CombineBbox($1,$2);'
        LANGUAGE 'sql' IMMUTABLE;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_Combine_BBox(box2d, geometry)
        RETURNS box2d AS
        'SELECT ST_CombineBbox($1,$2);'
        LANGUAGE 'sql' IMMUTABLE;

-- Availability: 1.2.2
-- Deprecation in 2.2.0
CREATE OR REPLACE FUNCTION ST_distance_sphere(geom1 geometry, geom2 geometry)
        RETURNS FLOAT8 AS
        'SELECT ST_DistanceSphere($1,$2);'
        LANGUAGE 'sql' IMMUTABLE STRICT;


