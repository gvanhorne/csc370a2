SELECT d.director, p.personname
FROM directors as d
INNER JOIN persons as p
ON d.director = p.pid
LIMIT 5;