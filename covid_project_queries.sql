--See what info both data sets contain. Data pulled from https://ourworldindata.org/covid-deaths as of 7/28/2021

SELECT *
FROM covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date

SELECT *
FROM covid_project.dbo.covid_vaccinations
WHERE continent IS NOT NULL
ORDER BY location, date

--Select data that we will be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date

--global fatality rate numbers as of 7/28/2021
--Tableau visualization #1

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS global_fatality_rate
FROM covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in the United States over time

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS fatality_rate
FROM covid_project.dbo.covid_deaths
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY location, date

--Looking at total cases vs population
--Shows what percentage of the United States population has been diagnosed with covid over time

SELECT location, population, date, total_cases, (total_cases / population) * 100 AS infection_rate
FROM covid_project.dbo.covid_deaths
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY location, date

--Death breakdown by continent
--Tableau visualization #2

DROP TABLE IF EXISTS #temp_deaths
CREATE TABLE #temp_deaths 
(
continent varchar(255),
location varchar(255),
highest_death_count int
)

INSERT INTO #temp_deaths
SELECT continent, location, MAX(cast(total_deaths AS int)) AS highest_death_count
FROM covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent, location

SELECT continent, SUM(highest_death_count) as highest_death_count_continent
FROM #temp_deaths
GROUP BY continent
ORDER BY highest_death_count_continent DESC

--Percentage of population infected worldwide over time
--Tableau visualization #3 and #4

SELECT location, population, date, MAX(total_cases) AS highest_infection_count, MAX(total_cases / population) * 100 AS infection_rate
FROM covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY infection_rate DESC

--Showing countries with most deaths

SELECT location, continent, MAX(cast(total_deaths AS int)) AS highest_death_count
FROM covid_project.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, continent
ORDER BY highest_death_count DESC

--create temp table to calculate percentage of poplulation vaccinated
--Tableau visualization #5

DROP TABLE IF EXISTS #percent_poplulation_vaccinated
CREATE TABLE #percent_poplulation_vaccinated
( 
location varchar(255),
date datetime,
population numeric,
people_fully_vaccinated numeric,
)

INSERT INTO #percent_poplulation_vaccinated
SELECT deaths.location, deaths.date, deaths.population, MAX(CAST(vax.people_fully_vaccinated AS numeric)) AS people_fully_vaccinated
FROM covid_project.dbo.covid_deaths AS deaths
JOIN covid_project.dbo.covid_vaccinations as vax
	ON deaths.location = vax.location AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL
GROUP BY deaths.location, deaths.date, deaths.population

SELECT *, (people_fully_vaccinated / population) * 100 as vaccination_percentage
FROM #percent_poplulation_vaccinated
ORDER BY location, date

