-- Data Exploration and Data Cleaning: Netflix Show Data

-- **************** --
-- Data Exploration --
-- **************** --

SELECT *
FROM NetflixProject..data_TV; 


-- find avg, max, min and std dev of vote and popularity
SELECT AVG(popularity) AS avg_popularity,
MAX(popularity) as max_popularity,
MIN(popularity) as min_popularity,
STDEV(popularity) as sd_popularity,
AVG(vote_average) AS avg_vote,
MAX(vote_average) as max_vote,
MIN(vote_average) as min_vote,
STDEV(vote_average) as sd_vote
FROM NetflixProject..data_TV; 

-- avg popularity = 60
-- max popularity = 6,685
-- min popularity = 0.9
-- sd popularity = 222 (large)

-- avg vote = 7.7
-- max vote = 9
-- min vote = 0.6
-- sd vote = 0.6

-- What date was the show with the highest vote released?
SELECT 
  FORMAT(first_air_date, 'MM-dd-yyyy', 'en-US') AS first_air_date,
  name,
  vote_average,
  popularity,
  origin_country
FROM NetflixProject..data_TV
WHERE vote_average = (SELECT MAX(vote_average) FROM NetflixProject..data_TV);
-- Highest vote average appears to have been for The D'Amelio Show released in Sept 2021
-- However, the popularity rating is quite low


-- Now, let's look at what show was the most popular
SELECT 
  FORMAT(first_air_date, 'MM-dd-yyyy', 'en-US') AS first_air_date,
  name,
  vote_average,
  popularity,
  origin_country
FROM NetflixProject..data_TV
WHERE popularity = (SELECT MAX(popularity) FROM NetflixProject..data_TV);
-- House of the Dragon was the most popular.
-- It also has a high voter average at 8.5


-- In which countries are the top most popular shows produced?
SELECT TOP 5 FORMAT(first_air_date, 'MM-dd-yyyy', 'en-US') AS first_air_date,
vote_average, popularity, origin_country, name
FROM NetflixProject..data_TV
ORDER BY popularity DESC;
-- Most popular shows were aired in 2022 and produced by the US
-- House of the Dragon, Monster: The Jeffrey Dahmer Story, The Lord of the Rings: The Rings of Power,
-- She-Hulk: Attorney at Law, and Rick and Morty


-- Count of shows by year - which year saw the most shows produced?
SELECT COUNT(name) AS shows_num,
YEAR(first_air_date) AS year
FROM NetflixProject..data_TV
GROUP BY YEAR(first_air_date)
ORDER BY year ASC;

-- The most shows were aired between 2020 and 2021
-- Perhaps there isn't enough data on older decades
-- However, it's true that Netflix has intensified 
-- the production of original content in the past few years
-- There are 6 shows that don't have an associated year


-- In which year did Japan produce the most shows?
-- Which Japanese show had the highest popularity rating?
SELECT COUNT(name) AS shows_num,
YEAR(first_air_date) AS year,
origin_country
FROM NetflixProject..data_TV
GROUP BY YEAR(first_air_date), origin_country
HAVING origin_country = 'JP'
ORDER BY year ASC;
-- Most of the Japanese shows on Netflix were released in 2018, 2019 and 2020


-- What is the most popular Japanese show?
SELECT popularity,
vote_average,
name,
YEAR(first_air_date) AS year
FROM NetflixProject..data_TV
WHERE origin_country = 'JP' AND popularity = (SELECT MAX(popularity) FROM NetflixProject..data_TV WHERE origin_country = 'JP');
-- Most popular Japanese show was SPY x FAMILY, released in 2022 with a popularity of 664 and a vote average of 8.7


-- What other Japanese shows were popular?
SELECT TOP 5 FORMAT(first_air_date, 'MM-dd-yyyy', 'en-US') AS first_air_date,
vote_average, popularity, origin_country, name
FROM NetflixProject..data_TV
WHERE origin_country = 'JP'
ORDER BY popularity DESC;
-- Other popular shows included Bleach, Jujutsu Kaisen, Super Dragon Ball Heroes and Dragon Ball Z
-- All of these are cartoons


-- Identify joint productions using regular expressions
-- Joint productions are those where origin country looks like c('Country1', 'Country2')
SELECT origin_country, 
count(name) as num_shows
FROM NetflixProject..data_TV
GROUP BY origin_country
HAVING origin_country LIKE '%c(%'
ORDER BY num_shows DESC;

-- Canada & US, UK & US, and Mexico & US have the most collaborations



-- ********************** --
-- Data Cleaning / Export --
-- ********************** --

-- In this section, I want to export some clean tables
-- to Tableau for additional viz and analysis

-- 1. Change first_air_date to a date format,
-- then extract year, month
-- 2. Create a column for if origin_country contains multiple countries - it has c("", "") pattern

SELECT FORMAT(first_air_date, 'MM-dd-yyyy', 'en-US') AS first_air_date,
YEAR(first_air_date) as air_year, MONTH(first_air_date) AS air_month,
origin_country, 
CASE WHEN origin_country LIKE '%c(%' THEN 1
ELSE 0
END AS origin_country_joint,
original_language, name, popularity, vote_average, vote_count
FROM NetflixProject..data_TV; 


-- Ideas for Data Viz (narrow down)

-- number of shows produced by year (line graph)
-- popularity and vote_average of 5 most popular shows
-- number of shows produced by country (treemap?)

-- can we show number of shows produced by year (in a country),
-- popularity and vote average of 5 most popular shows (in a country)
-- and have this dynamically change depending on country of release?
-- create a wordcloud in Tableau using overview column (should I clean this column first)?