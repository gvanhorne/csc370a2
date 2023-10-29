-- WITH directors_with_7_movies AS (
--   SELECT *
--   FROM (
--     select pid, count(pid) as n
--     FROM (
--       select pid, id
--       FROM persons AS p
--       JOIN directors AS d
--       ON p.pid = d.director
--     ) AS c
--     JOIN productions AS p
--     ON p.id = c.id
--     WHERE productiontype = 'movie'
--     GROUP BY pid
--   ) as d
--   WHERE n >= 7
-- ),

WITH great_movies AS (
  SELECT id
  FROM (
    SELECT p.id, r.averagerating, r.numvotes
    FROM ratings as r JOIN productions as p ON r.id = p.id
    WHERE productiontype = 'movie'
  ) as c
  WHERE c.averagerating >= 8.5 and c.numvotes >= 100000
),

great_directors AS (
  SELECT DISTINCT d.director
  FROM (
    great_movies as gm JOIN directors as d on gm.id = d.id
  )
  GROUP BY d.director
),

movies_by_great_directors AS (
  select p.id, gd.director
  FROM (
    great_directors as gd JOIN directors as d on gd.director = d.director
    JOIN productions as p on d.id = p.id and productiontype = 'movie'
  )
),

great_directors_with_7_movie_credits AS (
  SELECT director, COUNT(*) AS director_appearances
  FROM movies_by_great_directors
  GROUP BY director
  HAVING COUNT(*) >= 7
),

director_names AS (
  SELECT pid, personname as director
  FROM great_directors_with_7_movie_credits as gd
  JOIN persons as p on p.pid = gd.director
)

select * from director_names;