DROP TYPE IF EXISTS series_detail;
CREATE TYPE series_detail AS (
  title text,
  year integer,
  nseasons bigint,
  nepisodes bigint,
  runtime integer,
  avgrating double precision,
  votes integer
);

-- CREATE OR REPLACE FUNCTION user014_series(title text)
-- RETURNS series_detail AS $$
--   SELECT * from productions as p where p.title = title;
-- $$ LANGUAGE SQL;

WITH series_id AS (
  SELECT *
  FROM productions as p
  JOIN episodes as e
  ON p.id = e.episodeof
  WHERE p.title = 'Star Trek'
  AND productiontype = 'tvSeries'
),

nseasons AS (
  SELECT episodeof, COUNT(DISTINCT season) as nseasons
  FROM series_id
  GROUP BY episodeof
),

nepisodes AS (
  SELECT episodeof, COUNT(*) as nepisodes
  FROM series_id as s
  GROUP BY episodeof
),

rating_info AS (
  SELECT episodeof, averagerating as avgrating, numvotes as votes
  FROM (
    SELECT DISTINCT episodeof, numvotes, averagerating FROM series_id as s
    JOIN ratings as r ON r.id = s.episodeof
  ) as c
)

select DISTINCT title, year, ns.nseasons, ne.nepisodes, runtime, avgrating, votes
FROM series_id as s JOIN nseasons as ns ON s.episodeof = ns.episodeof
JOIN nepisodes as ne ON ne.episodeof = s.episodeof
JOIN rating_info as ar ON s.episodeof = ar.episodeof;