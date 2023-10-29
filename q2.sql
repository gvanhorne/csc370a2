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
)

select count(*) from four_seasons;