/*
Data Exploration in Microsoft SQL Server
using Covid 19 Dataset
*/

-- Viewing the tables
-- Ordering by location (3) and date (4)

SELECT * FROM CovidDeaths
	ORDER BY 3,4		
SELECT * FROM CovidVaccinations
	ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Total Cases vs Total Death in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'India'
	AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population in India

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationInfected
FROM CovidDeaths
WHERE location = 'India'
	AND continent IS NOT NULL
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HigestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
	GROUP BY location, population
	ORDER BY PopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL  --removes unwanted entries like world etc
	GROUP BY location
	ORDER BY TotalDeathCount DESC
	

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
 
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL  --removes unwanted entries like world etc
	GROUP BY continent
	ORDER BY TotalDeathCount DESC

-- Continents with the highest death count

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL  --removes unwanted entries like world etc
	GROUP BY continent
	ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT date, SUM(new_cases) AS TotalCases, 
	SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY 1,2

-- Number of cases, death and death percentage of all the world

SELECT SUM(new_cases) AS TotalCases, 
	SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
	WHERE continent IS NOT NULL
	ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	ORDER BY 2,3

-- Making a rolling count

SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVacs
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	ORDER BY 2,3

-- Vaccination rolling count for india

SELECT cd.location, cd.date, population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER 
	(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVacs
FROM CovidDeaths cd
JOIN CovidVaccinations cv 
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL AND cd.location = 'India'
ORDER BY 2,3

-- Using CTE to query TotalVacs by Population percetange in the above query

WITH PopVsVac (continent, location, date, population, new_vaccincations ,TotalVacs)
AS 
(
	SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVacs
	FROM CovidDeaths cd
	JOIN CovidVaccinations cv 
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	--ORDER BY 2,3
)
SELECT *, (TotalVacs/population)*100 
FROM PopVsVac

-- Writing the same query for India

WITH IndPopVsVac (location, date, population, new_vaccinations, TotalVacs)
AS 
(
	SELECT cd.location, cd.date, population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVacs
	FROM CovidDeaths cd
	JOIN CovidVaccinations cv 
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL AND cd.location = 'India'
	--ORDER BY 2,3
)
SELECT *, (TotalVacs/population)*100
FROM IndPopVsVac --YOU WILL FIND MORE THAN 100 PERCENT BECAUSE OF DOUBLE VACC POLICY


-- WRITING THE SAME QUERY USING TEMP TABLES

--DROP TABLE IF EXISTS #PerPopVac
CREATE TABLE #PerPopVac
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVacs numeric)

INSERT INTO #PerPopVac
	SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVacs
	FROM CovidDeaths cd
	JOIN CovidVaccinations cv 
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *, (TotalVacs/population)*100 
FROM #PerPopVac

-- Creating a temp table for Totalvacs by population for india

--DROP TABLE IF EXISTS #IndPopVsVac 
CREATE TABLE #IndPopVsVac 
(
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVacs numeric
)
INSERT INTO #IndPopVsVac
	SELECT cd.location, cd.date, population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVacs
	FROM CovidDeaths cd
	JOIN CovidVaccinations cv 
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL AND cd.location = 'India'
	--ORDER BY 2,3

SELECT * FROM #IndPopVsVac

-- CREATING A VIEW

-- For global total

GO
CREATE VIEW VGlobalTotal AS
SELECT SUM(new_cases) AS TotalCases, 
	SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GO

SELECT * FROM VGlobalTotal

-- For ind pop vs vac

GO
CREATE VIEW VIndPopVsVac AS
	SELECT cd.location, cd.date, population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVacs
	FROM CovidDeaths cd
	JOIN CovidVaccinations cv 
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL AND cd.location = 'India'
	--ORDER BY 2,3
GO

SELECT * FROM VIndPopVsVac

-- For global pop vs vac

GO
CREATE VIEW VPopVsVac AS
	SELECT cd.continent, cd.location, cd.date, population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS TotalVacs
	FROM CovidDeaths cd
	JOIN CovidVaccinations cv 
		ON cd.location = cv.location AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	--ORDER BY 2,3
GO

SELECT * FROM VPopVsVac

-- For total death by continent

GO
CREATE VIEW VContTotalDeath AS
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL  --removes unwanted entries like world etc
GROUP BY continent
--ORDER BY TotalDeathCount DESC
GO

SELECT * FROM VContTotalDeath
ORDER BY TotalDeathCount DESC

-- For percentage of death by population in india

GO
CREATE VIEW VIndPerDeath AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
--ORDER BY 1,2
GO

SELECT * FROM VIndPerDeath

-- For percent of people infected by population in india

GO
CREATE VIEW VIndPerInf AS
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationInfected
FROM CovidDeaths
WHERE location = 'India'
AND continent IS NOT NULL
--ORDER BY 1,2
GO

SELECT * FROM VIndPerInf
ORDER BY 2

/*
Queries used for Tableau Project
*/

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
