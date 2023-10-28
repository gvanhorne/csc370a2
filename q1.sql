WITH movie_directors_2002 AS (
  select pid, count(pid) as n2002
  FROM (
    select pid, id
    FROM persons AS p
    JOIN directors AS d
    ON p.pid = d.director
  ) AS c
  JOIN productions AS p
  ON p.id = c.id
  WHERE productiontype = 'movie' AND year = '2002'
  GROUP BY pid
),

most_prolific_2002_movie_directors AS (
  SELECT * from movie_directors_2002
  WHERE n2002 = (SELECT MAX(n2002) FROM movie_directors_2002)
),

prolific_directors_names AS (
  select pid, personname
  FROM persons
  WHERE pid
  IN (
    SELECT pid
    FROM most_prolific_2002_movie_directors
  )
),

lifetime_productions AS (
  select pid, id
  FROM most_prolific_2002_movie_directors as p
  JOIN directors as d
  ON p.pid = d.director
),

productions_by_type AS (
  select l.pid, p.productiontype, count(productiontype) as n
  FROM productions as p
  JOIN lifetime_productions as l
  ON p.id = l.id
  GROUP by l.pid, p.productiontype
)

SELECT
  n.pid, n.personname, t.productiontype, m.n2002, t.n
FROM (
  productions_by_type as t
  JOIN prolific_directors_names AS n ON t.pid = n.pid
  JOIN movie_directors_2002 as m ON t.pid = m.pid
);
