WITH max_2002_movies AS (
  SELECT pid, count(pid) as n2002
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

director_names AS (
  select pid, personname
  FROM persons
  WHERE pid
  IN (
    SELECT pid
    FROM max_2002_movies
  )
)

SELECT m.pid, personname, n2002
FROM (max_2002_movies as m INNER JOIN director_names as p ON p.pid = m.pid)
WHERE n2002 = (SELECT MAX(n2002) FROM max_2002_movies);