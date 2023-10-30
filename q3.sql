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

movies_by_great_directors_with_7_movie_credits AS (
  SELECT id
  FROM movies_by_great_directors AS md JOIN great_directors_with_7_movie_credits as d
  ON md.director = d.director
),

nother AS (
  SELECT director, count(*) as nother
  FROM (
    movies_by_great_directors_with_7_movie_credits AS md
    JOIN ratings as r ON md.id = r.id
    JOIN directors as d
    ON md.id = d.id
    JOIN productions as p ON p.id = d.id
  )
  WHERE md.id NOT IN (SELECT id from great_movies)
  GROUP BY director
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
select dn.pid, dn.director, ng.ngreat, nm.nother, (ngreat::decimal / (ngreat + nother)) AS prop
FROM (
  director_names as dn JOIN ngreat as ng ON dn.pid = ng.director
  JOIN nother as nm ON nm.director = dn.pid
);