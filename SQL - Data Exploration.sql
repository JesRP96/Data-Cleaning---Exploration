USE Portfolio_Project

SELECT *
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
ORDER BY 3,4

/*
SELECT *
FROM Portfolio_Project..Covid_Vaccinations
ORDER BY 3,4 */

-- Selecting data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Portfolio_Project..Covid_Deaths
-- WHERE location = 'Mexico'
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths for Mexico
-- Shows the likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPorcentage
FROM Portfolio_Project..Covid_Deaths
-- WHERE location = 'Mexico'
ORDER BY 5 DESC



/*-- Looking at total case fatality rate for all countries in the world (Using a view)
CREATE VIEW Total_Deaths_per_Location AS
SELECT location, total_deaths, total_cases,population, (total_deaths/total_cases)*100 Case_Fatality_Rate
FROM Portfolio_Project..Covid_Deaths
WHERE date = '2021-07-26 00:00:00.000'
ORDER BY 5 DESC

SELECT location, total_deaths, date, population
FROM Portfolio_Project..Covid_Deaths
WHERE location = 'Mexico'
ORDER BY 3 DESC


SELECT location,(Total_Deaths/Total_Cases)*100 as Case_Fatality_Rate
FROM Location_Totals
-- WHERE location like '%states%'
ORDER BY 2 DESC*/

-- Looking at total cases vs population Mexico
CREATE VIEW Latest_Cases_per_Location AS
SELECT location, population,  date, total_cases, (total_cases/population)*100 Cases_Percentage
FROM Portfolio_Project..Covid_Deaths
WHERE location = 'Mexico'
ORDER BY 2,3

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as Total_Cases, MAX((total_cases/population))*100 as Infection_Rate
FROM Portfolio_Project..Covid_Deaths
GROUP BY location, population
ORDER BY 4 DESC

-- Showing the countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

-- Lets break out things by continent
-- Showing the continents with the highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC

-- Look at things as you are going to visualize this
-- You can drill down stuff (All NorthAmerica to show all of the countried there)

-- Global numbers
-- Global total deaths vs total cases
SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as Case_Fatality_Rate
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
ORDER BY 1 DESC

-- Global total deaths vs total cases daily
SELECT date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as Case_Fatality_Rate
FROM Portfolio_Project..Covid_Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1 DESC


-- Looking at Total Population vs Vaccinations
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location ORDER BY CD.location, CV.date) as RollingPeopleVaccinated
FROM Portfolio_Project..Covid_Deaths CD
JOIN Portfolio_Project..Covid_Vaccinations CV
	ON CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location ORDER BY CD.location, CV.date) as RollingPeopleVaccinated
FROM Portfolio_Project..Covid_Deaths CD
JOIN Portfolio_Project..Covid_Vaccinations CV
	ON CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentageOfPeopleVaccinated
FROM PopvsVac
WHERE Location = 'Mexico'


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location ORDER BY CD.location, CV.date) as RollingPeopleVaccinated
FROM Portfolio_Project..Covid_Deaths CD
JOIN Portfolio_Project..Covid_Vaccinations CV
	ON CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null

SELECT *,(RollingPeopleVaccinated/Population)*100 AS PercentageOfPeopleVaccinated
FROM #PercentPopulationVaccinated


-- Creating VIEW to Store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location ORDER BY CD.location, CV.date) as RollingPeopleVaccinated
FROM Portfolio_Project..Covid_Deaths CD
JOIN Portfolio_Project..Covid_Vaccinations CV
	ON CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null

SELECT *
FROM PercentPopulationVaccinated