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
)

select * from filtered_seasons;