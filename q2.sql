with unique_seasons AS (
  select episodeof, season
  FROM episodes
  GROUP BY episodeof, season
),

four_seasons AS (
  SELECT episodeof
  FROM unique_seasons
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
)

select * from most_episodes;