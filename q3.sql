WITH directors_with_7_movies AS (
  SELECT *
  FROM (
    select pid, count(pid) as n
    FROM (
      select pid, id
      FROM persons AS p
      JOIN directors AS d
      ON p.pid = d.director
    ) AS c
    JOIN productions AS p
    ON p.id = c.id
    WHERE productiontype = 'movie'
    GROUP BY pid
  ) as d
  WHERE n >= 7
)

select * from directors_with_7_movies;