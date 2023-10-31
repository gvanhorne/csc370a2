CREATE OR REPLACE FUNCTION user014_episodes(title text)
RETURNS SETOF seasons AS $$
  WITH series_detail AS (
    SELECT *
    FROM productions as p
    JOIN episodes as e
    ON p.id = e.episodeof
    WHERE p.title = $1
    AND productiontype = 'tvSeries'
  ),

  series_id AS (
    SELECT DISTINCT episodeof
    FROM series_detail
  ),

  nseasons AS (
    SELECT episodeof, season
    FROM series_detail
    GROUP BY episodeof, season
  ),

  all_episode_ids AS (
    SELECT id, season from episodes where episodeof IN (SELECT episodeof FROM nseasons)
  ),

  season_years AS (
    SELECT p.id, p.year, e.season
    FROM productions as p JOIN all_episode_ids as e ON p.id = e.id
    ORDER BY p.year ASC
  ),

  SeasonFirstYear AS (
    SELECT season, MIN(year) AS first_year
    FROM season_years
    GROUP BY season
    ORDER BY first_year ASC
  ),

  avg_votes AS (
    SELECT season, AVG(numvotes) AS avgvotes
    FROM ratings as r JOIN all_episode_ids as i on r.id = i.id
    GROUP BY season
  ),

  avg_rating AS (
    SELECT season, AVG(averagerating) AS avgrating
    FROM ratings as r JOIN all_episode_ids as i on r.id = i.id
    GROUP BY season
  ),

  series_rating AS (
    SELECT averagerating as avgseriesrating
    FROM series_id as s JOIN ratings as r on s.episodeof = r.id
  )

  SELECT
    s.season::text,
    s.first_year,
    count(*) as episodes,
    round(avgvotes, 1)::double precision as avgvotes,
    ROUND(avgrating::numeric, 1)::double precision as avgrating,
    ROUND((avgrating - (SELECT avgseriesrating FROM series_rating))::numeric, 1)::double precision as diff
  FROM (
    SeasonFirstYear as s JOIN all_episode_ids as e ON s.season = e.season
    JOIN avg_votes as av ON s.season = av.season
    JOIN avg_rating as ar ON s.season = ar.season
  )
  GROUP BY s.season, s.first_year, avgvotes, avgrating
  ORDER BY s.season is null, s.season ASC;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION user014_series(title text)
RETURNS series AS $$
  WITH series_id AS (
    SELECT *
    FROM productions as p
    JOIN episodes as e
    ON p.id = e.episodeof
    WHERE p.title = $1
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

  select DISTINCT s.title, year, ns.nseasons, ne.nepisodes, runtime, avgrating, votes
  FROM series_id as s JOIN nseasons as ns ON s.episodeof = ns.episodeof
  JOIN nepisodes as ne ON ne.episodeof = s.episodeof
  JOIN rating_info as ar ON s.episodeof = ar.episodeof;
$$ LANGUAGE SQL;

-- SELECT * FROM user014_series('Star Trek');