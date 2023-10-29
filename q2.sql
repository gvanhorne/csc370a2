with all_seasons AS (
  select episodeof, season
  FROM episodes
  GROUP BY episodeof, season
),

four_seasons AS (
  SELECT episodeof
  FROM all_seasons
  GROUP BY episodeof
  HAVING COUNT(DISTINCT season) >= 4
),

most_episodes_desc AS (
  SELECT e.episodeof, count(e.episodeof) as n
  FROM
    (
      four_seasons as f JOIN episodes as e ON f.episodeof = e.episodeof
    )
  GROUP BY e.episodeof
  ORDER BY n DESC
),

most_episodes AS (
  SELECT episodeof from most_episodes_desc
  WHERE n = (SELECT MAX(n) FROM most_episodes_desc)
),

filtered_seasons AS (
  select m.episodeof, e.season
  FROM (
    episodes as e JOIN most_episodes as m ON e.episodeof = m.episodeof
  )
  GROUP BY m.episodeof, e.season
),

title AS (
  select title, p.id
  FROM (
    productions as p JOIN filtered_seasons as f ON p.id = f.episodeof
  )
),

all_episode_ids AS (
  SELECT id, f.season
  FROM
    (
      filtered_seasons as f JOIN episodes as e
        ON f.episodeof = e.episodeof and (f.season = e.season or f.season is null and e.season is null)
    )
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
)

select * from SeasonFirstYear;
-- SELECT S.id, S.year, S.season,
--        SUM(1) OVER (PARTITION BY S.season ORDER BY S.year) AS season_episode_count
-- FROM season_years AS S
-- JOIN SeasonFirstYear AS F ON S.season = F.season

-- starting to build final relation...
-- SELECT DISTINCT t.title, f.season
-- FROM
--   (
--     filtered_seasons AS f
--     JOIN title AS t ON f.episodeof = t.id
--   )
-- ORDER BY f.season ASC;