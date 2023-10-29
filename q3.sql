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
)

-- movies_by_directors_with_7_movie_credits AS (
--   SELECT c.director
--   FROM (
--     SELECT gm.id, d.director FROM great_movies as gm JOIN directors as d on gm.id = d.id
--     GROUP BY gm.id, d.director
--   ) as c
--   GROUP BY c.director
--   HAVING COUNT(*) >= 7
-- )

select * from great_movies;