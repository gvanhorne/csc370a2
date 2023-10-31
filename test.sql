WITH series_detail AS (
  SELECT *
  FROM productions as p
  JOIN episodes as e
  ON p.id = e.episodeof
  WHERE p.title = 'Borgen'
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
  s.season,
  s.first_year,
  count(*) as episodes,
  round(avgvotes, 1) as avgvotes,
  ROUND(avgrating::numeric, 1) as avgrating,
  ROUND((avgrating - (SELECT avgseriesrating FROM series_rating))::numeric, 1) as diff
FROM (
  SeasonFirstYear as s JOIN all_episode_ids as e ON s.season = e.season
  JOIN avg_votes as av ON s.season = av.season
  JOIN avg_rating as ar ON s.season = ar.season
)
GROUP BY s.season, s.first_year, avgvotes, avgrating
ORDER BY season is null, season ASC;
