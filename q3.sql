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
  SELECT director
  FROM movies_by_great_directors
  GROUP BY director
  HAVING COUNT(*) >= 7
),

director_names AS (
  SELECT pid, personname as director
  FROM great_directors_with_7_movie_credits as gd
  JOIN persons as p on p.pid = gd.director
),

ngreat AS (
  SELECT director, count(*) as ngreat
  FROM (
    SELECT gm.id, d.director
    FROM great_movies as gm JOIN directors as d ON gm.id = d.id
  ) as c
  GROUP BY director
)

-- Starting to build output query...
select *
FROM (
  director_names as dn JOIN ngreat as ng ON dn.pid = ng.director
);