use Pixar_Db;
Select * from academy;
Select * from box_office;
Select * from genres;
Select * from pixar_films;
Select * from pixar_people;
Select * from public_response;
ALTER TABLE pixar_people
CHANGE COLUMN column1 film VARCHAR(255);
ALTER TABLE pixar_people
CHANGE COLUMN column2 role_type varchar(255);
ALTER TABLE pixar_people
CHANGE COLUMN column3 name varchar(255);
ALTER TABLE genres
CHANGE COLUMN value Movie_Genres varchar(255);

select pf.*,g.*,pp.role_type,pp.name from pixar_films pf join genres g on pf.film=g.film left join pixar_people pp on pf.film=pp.film;

ALTER TABLE pixar_films
ADD COLUMN release_year INT,
ADD COLUMN release_month INT;
SET SQL_SAFE_UPDATES = 0;
UPDATE pixar_films
SET
  release_year = YEAR(STR_TO_DATE(release_date, '%d-%m-%Y')),
  release_month = MONTH(STR_TO_DATE(release_date, '%d-%m-%Y'));  

-- 1.Select the film titles and their release years

SELECT film, release_year
FROM pixar_films order by release_year desc;

-- 2.List all unique genre types

SELECT DISTINCT category
FROM genres;

-- 3.1 Join pixar_films and genres  to show film titles with their corresponding genres

SELECT distinct pf.film, g.category,g.Movie_Genres
FROM pixar_films AS pf
JOIN genres AS g
ON pf.film = g.film
having category = 'genre';

-- 3.2 Join pixar_films and genres  to show film titles with their corresponding sub_genres

SELECT distinct pf.film, g.category,g.Movie_Genres
FROM pixar_films AS pf
JOIN genres AS g
ON pf.film = g.film
having category = 'subgenre';

-- 4.Find the worldwide box office gross for each film

SELECT pf.film, bo.box_office_worldwide
FROM pixar_films AS pf
JOIN box_office AS bo
ON pf.film = bo.film
order by bo.box_office_worldwide desc;

-- 5.List all films and their directors

SELECT film, name AS director_name
FROM pixar_people
WHERE role_type = 'Director';

-- 6.Calculate the average Tomatometer score for all films

SELECT AVG(rotten_tomatoes_score) AS avg_tomatometer
FROM public_response;

-- 7.Find the highest-grossing film and its worldwide gross

SELECT film, box_office_worldwide
FROM box_office
ORDER BY box_office_worldwide DESC
LIMIT 1;

-- 8.Count the total number of films in the database

SELECT COUNT(*) AS total_films
FROM pixar_films;

-- 9.1 Show all films, their genres, and their directors

SELECT distinct pf.film, g.category,g.movie_genres,pf.name as Director_name
FROM pixar_people AS pf
left JOIN genres AS g
ON pf.film = g.film
where pf.role_type = 'Director' and g.category = 'genre';

-- 9.1 Show all films, their Subgenres, and their directors

SELECT distinct pf.film, g.category,g.movie_genres,pf.name as Director_name
FROM pixar_people AS pf
left JOIN genres AS g
ON pf.film = g.film
where pf.role_type = 'Director' and g.category = 'subgenre';

-- 10.Find films released before the year 2010

select film,release_year from pixar_films
where release_year < 2010 ;

-- 11.List all films with a worldwide gross over $500 million

select film,box_office_worldwide from box_office 
where box_office_worldwide >= 500000000;  

-- 12.Find the number of Academy Award wins for each film

SELECT film, COUNT(award_type) AS total_wins
FROM academy
WHERE status = 'Won' or status = 'Won Special Achievement'
GROUP BY film;

-- 13.List films that have won at least 2 Academy Awards

SELECT film, COUNT(award_type) AS total_wins
FROM academy
WHERE status = 'Won' or status = 'Won Special Achievement'
GROUP BY film
having total_wins >= 2;

-- 14.Find films with a Tomatometer score above 90% and their corresponding audience score

select film,rotten_tomatoes_score,`audience score`
 from public_response where rotten_tomatoes_score > 90;

-- 15.Identify the directors who have directed more than one film

select name as director_name,count(film) as Number_of_films from pixar_people 
where role_type = 'director'
group by name
having number_of_films >1
order by number_of_films desc;

-- 16.Find the average worldwide gross for each genre

select g.category,g.movie_genres as genres ,avg(bo.box_office_worldwide) as Avg_World_Gross
 from genres g  join box_office bo 
on g.film = bo.film
group by g.category,g.movie_genres
having g.category = 'genre';

-- 17.Find the film with the highest worldwide gross using a subquery

SELECT film, box_office_worldwide
FROM box_office
WHERE box_office_worldwide = (SELECT MAX(box_office_worldwide) FROM box_office);

-- 18.List all films that are also nominated for an Academy Award

select distinct film,award_type from academy where status in ('nominated','won','Won Special Achievement')
order by film asc;

-- 19.Show the films and their directors for films with a Tomatometer score over 90

Select pr.film,pp.name as directors
from public_response pr join pixar_people pp
on pr.film = pp.film 
and pp.role_type = 'Director' where pr.rotten_tomatoes_score >= 90;

-- 20.Find the average Tomatometer score for films that have won at least one Academy Award

select avg(pr.rotten_tomatoes_score) as avg_Tomatometer_score
from public_response pr join academy a on
pr.film = a.film 
where a.status = 'won';

-- 21.Most Profitable Films by Worldwide Gross

select film,(box_office_worldwide - budget) as Profit from box_office
Order by profit desc; 

-- 22.Films with Multiple Genres

select film,count(movie_genres) as genres from genres
where category = 'genre'
group by film;

-- 23.Directors with Highest Average Audience Score

select pp.name as directors,avg(`Audience Score`) as Avg_Audience_Score
from pixar_people pp join public_response pr on pp.film = pr.film
where pp.role_type = 'Director'
group by pp.name
order by Avg_Audience_Score desc
limit 1;

-- 24.Ranking Films by Worldwide Gross Using Window Functions

select film,box_office_worldwide,
rank() over (order by box_office_worldwide desc) as ranks
from box_office;

-- 25.Films with Highest Tomeratometer_Score in Each Genre

SELECT film,category,rotten_tomatoes_score
FROM (
    SELECT g.film, g.category, pr.rotten_tomatoes_score,
           RANK() OVER (PARTITION BY g.category ORDER BY pr.rotten_tomatoes_score DESC) AS rnk
    FROM genres AS g
    JOIN public_response AS pr ON g.film = pr.film where g.category = 'genre' 
) AS ranked_films
WHERE rnk = 1;

-- 26.Subquery to Find Films with No Academy Award Wins

select film from pixar_films 
where film not in(select distinct film from academy where status in ('won','Won Special Achievement'));

-- 27.Films with More Than Two Nominations but No Wins

select film from academy 
group by film
having (sum(case when status = 'nominated' then 1 else 0 end )) > 2 and
      (sum(case when status in ('won','Won Special Achievement') then 1 else 0 end )) =0 ;

-- 28.Total Revenue per Director

select pp.name as directors,
sum(bo.box_office_worldwide) as revenue_of_directors
from pixar_people pp join box_office bo
on pp.film = bo.film
where pp.role_type = 'Director'
group by pp.name;

-- 29.Conditional Aggregation to Count Wins and Nominations in a Single Query

select film,
sum(case when status = 'nominated' then 1 else 0 end ) as total_nominated,
      sum(case when status in ('won','Won Special Achievement') then 1 else 0 end ) as total_Won
from academy
group by film;

-- 30.List All Film, Director, Genre, and Box Office Info

-- Genre

select pf.film,pp.name,g.movie_genres,bo.box_office_worldwide 
from pixar_films pf left join pixar_people pp
on pf.film = pp.film and pp.role_type = 'Director' 
left join genres g on pp.film = g.film and g.category = 'genre'
left join box_office bo on g.film = bo.film;

-- SubGenre

select pf.film,pp.name,g.movie_genres,bo.box_office_worldwide 
from pixar_films pf left join pixar_people pp
on pf.film = pp.film and pp.role_type = 'Director' 
left join genres g on pp.film = g.film and g.category = 'subgenre'
left join box_office bo on g.film = bo.film;

-- 31.Most Common Genres

select category,count(movie_genres) as film_counts from 
genres group by category,movie_genres
order by film_counts desc
limit 1 ;

-- 32.Films That Have Both a High Tomatometer and a High Audience Score

SELECT film, rotten_tomatoes_score, `Audience Score`
FROM public_response
WHERE rotten_tomatoes_score > 90 AND `Audience Score` > 90;

-- 33.Films and the Number of People Credited

SELECT film, COUNT(*) AS number_of_people
FROM pixar_people
GROUP BY film
Order by number_of_people desc;

-- 34.Rolling Average of Worldwide Gross Over Release Years

select release_year,Avg(bo.box_office_worldwide) over(order by pf.release_year) as rolling_avg_WW
from pixar_films pf join box_office bo 
on pf.film = bo.film 
group by release_year,box_office_worldwide;

-- 35.Films with Higher Than Average Audience Score

SELECT film, `Audience Score`
FROM public_response
WHERE `Audience Score` > (SELECT AVG(`Audience Score`) FROM public_response);

-- 36.Films with the Same Director and Genre

SELECT T1.film, T1.category,T1.Movie_Genres, T1.director
FROM (
    SELECT g.film, g.category,g.Movie_Genres, pp.name AS director,
           COUNT(*) OVER (PARTITION BY pp.name, g.category) AS count_films
    FROM genres AS g
    JOIN pixar_people AS pp ON g.film = pp.film
    WHERE pp.role_type = 'Director' and g.category = 'Genre'
) AS T1
WHERE T1.count_films > 1
order by director asc,Movie_genres asc ,film asc;

-- 37.Most Awarded Film by the Number of Nominations and Wins

SELECT film, COUNT(*) AS total_awards
FROM academy
GROUP BY film
ORDER BY total_awards DESC
LIMIT 1;

-- 38.Films Released in a Specific Decade

SELECT film, release_year
FROM pixar_films
WHERE release_year BETWEEN 2000 AND 2009
order by release_year asc;

-- 39. Average Scores for Films with a Budget Over a Certain Amount

SELECT AVG(pr.rotten_tomatoes_score) AS avg_tomatometer, AVG(pr.`Audience Score`) AS avg_audience_score,bo.budget
FROM public_response AS pr
JOIN box_office AS bo ON pr.film = bo.film
WHERE bo.budget > 150000000
group by budget;

-- 40.Count of Films by Director Role

SELECT pp.role_type, COUNT(DISTINCT pp.film) AS film_count
FROM pixar_people AS pp
WHERE pp.role_type = 'Director'
GROUP BY pp.role_type;

-- 41.Total Awards per Year

SELECT pf.release_year, COUNT(a.film) AS total_awards
FROM pixar_films AS pf
JOIN academy AS a ON pf.film = a.film
GROUP BY pf.release_year
ORDER BY pf.release_year asc;

-- 42.Films and their Budgets, ordered by Worldwide Gross

Select film,budget,box_office_worldwide from box_office 
order by box_office_worldwide desc;

-- 43.Director who has Directed Both Animated and Live-Action Films

SELECT pp.name
FROM pixar_people AS pp
JOIN genres AS g ON pp.film = g.film
WHERE pp.role_type = 'Director'
GROUP BY pp.name
HAVING SUM(CASE WHEN g.movie_genres = 'Animated' THEN 1 ELSE 0 END) > 0
   AND SUM(CASE WHEN g.movie_genres = 'Action' THEN 1 ELSE 0 END) > 0;

-- 44.Average Tomatometer Score by Genre

SELECT g.category, AVG(pr.rotten_tomatoes_score) AS avg_tomatometer
FROM genres AS g
JOIN public_response AS pr ON g.film = pr.film
GROUP BY g.category;

-- 45.Most Nominated Films with an Award Status

SELECT film, COUNT(*) AS total_nominations
FROM academy
WHERE status = 'nominated'
GROUP BY film
ORDER BY total_nominations DESC
limit 1;

-- 46.Films with a Budget under $100 Million that Grossed over $500 Million

select film,budget,box_office_worldwide
from box_office 
where budget < 100000000 and box_office_worldwide > 500000000 
order by film;

-- 47.Find the top 3 highest-grossing films and their genres

select bo.film,g.category,bo.box_office_worldwide as box_grossing 
from box_office bo join genres g 
where category = 'genre' 
group by film,category,box_office_worldwide
order by box_grossing desc
limit 3;

-- 48.Find the average runtime for each film rating

SELECT
  film_rating,
  AVG(run_time) AS avg_run_time
FROM pixar_films
GROUP BY
  film_rating
  order by avg_run_time desc;
  
--  49.List the films with both release_date and run_time values above the overall average
  
SELECT film,release_date,run_time
FROM pixar_films
WHERE release_date > 
	(SELECT AVG(release_date) 
FROM pixar_films) AND run_time > 
	(SELECT AVG(run_time) FROM pixar_films);    
    
-- 50.Calculate the difference between each film's worldwide gross and the next highest-grossing film    

SELECT film,box_office_worldwide,
LEAD(box_office_worldwide, 1) OVER (ORDER BY box_office_worldwide DESC) AS next_highest_gross,
box_office_worldwide - LEAD(box_office_worldwide, 1) OVER (ORDER BY box_office_worldwide DESC) AS gross_difference
FROM box_office
ORDER BY box_office_worldwide DESC;

-- 51.Find the top 5 films with the best audience-to-critic score ratio

-- A.Based on metacritic_score

SELECT film,`audience score`,
metacritic_score,(`audience score` / metacritic_score) AS score_ratio
FROM public_response
ORDER BY score_ratio DESC
LIMIT 5;

-- B.Based on rotten_tomatoes_score

SELECT film,`audience score`,
rotten_tomatoes_score,(`audience score` / rotten_tomatoes_score) AS score_ratio
FROM public_response
ORDER BY score_ratio DESC
LIMIT 5;
