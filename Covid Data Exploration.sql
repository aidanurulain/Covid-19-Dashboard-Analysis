SELECT *
FROM coviddeaths;

SET SQL_SAFE_UPDATES = 0;

UPDATE coviddeaths
SET continent = NULLIF(continent, '');

UPDATE coviddeaths
SET location = NULLIF(location, '');

SELECT *
FROM covidvaccinations;

-- Table 1 shows total case, total death & deathpercentage for location=country only
DROP TEMPORARY TABLE IF EXISTS temp_covid_summary;

CREATE TEMPORARY TABLE temp_covid_summary AS
SELECT location,SUM(new_cases) as totalcases,SUM(CAST(new_deaths AS FLOAT)) as totaldeaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location;

SELECT SUM(totalcases) as totalcases,SUM(totaldeaths) as totaldeaths ,(SUM(totaldeaths)/SUM(totalcases))*100 as totaldeathspercent
FROM temp_covid_summary;

-- Table 2 shows total death count per location
DROP TEMPORARY TABLE IF EXISTS temp_totaldeaths;

CREATE TEMPORARY TABLE temp_totaldeaths AS
SELECT continent,location, SUM(CAST(new_deaths AS FLOAT)) as totaldeaths
FROM coviddeaths
WHERE continent IS NULL AND location NOT IN ('World','European Union','International') OR continent = 'Asia'
GROUP BY continent,location
ORDER BY totaldeaths DESC;


-- A) Extract total death per location except for asia 
CREATE TEMPORARY TABLE temp_totaldeathslocation
SELECT location, SUM(totaldeaths) AS totaldeathsnew
FROM temp_totaldeaths
WHERE continent IS NULL
GROUP BY location;

-- B) Extract total death per location in asia only
DROP TEMPORARY TABLE IF EXISTS temp_totaldeathsasia;

CREATE TEMPORARY TABLE temp_totaldeathsasia
SELECT continent,SUM(totaldeaths) totaldeathsnew
FROM temp_totaldeaths
WHERE continent = 'Asia';

ALTER TABLE temp_totaldeathsasia
CHANGE COLUMN continent location TEXT;

SELECT *
FROM temp_totaldeathsasia;

SELECT *
FROM temp_totaldeathslocation;

-- Table 2 final - Combine table A + table
SELECT location, SUM(CAST(totaldeathsnew AS FLOAT)) AS totaldeaths2
FROM temp_totaldeathsasia
GROUP BY location
UNION ALL
SELECT location, SUM(CAST(totaldeathsnew AS FLOAT)) AS totaldeaths2
FROM temp_totaldeathslocation
GROUP BY location;



-- Table 3 shows highest infection count & infection percentage 
SELECT location,
	   population,
	   MAX(total_cases) as highestinfectioncount, 
	   (MAX(total_cases)/(Population))*100 AS percentpopulationinfected
FROM coviddeaths
GROUP BY location,population
ORDER BY percentpopulationinfected DESC;

-- Table 4 shows highest infection count & infection percentage with date
SELECT location,
	   date,
	   population,
	   MAX(total_cases) as highestinfectioncount, 
	   (MAX(total_cases)/(Population))*100 AS percentpopulationinfected
FROM coviddeaths
GROUP BY location,population,date
ORDER BY percentpopulationinfected DESC;













