-- Select all crew appearances for a given director
SELECT *
FROM crew
WHERE pid
IN (
  SELECT director
  FROM directors
)
and crewtype = 'director'
limit 10;