
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population
-- shows what percentage of population contracted Covid

SELECT location, date, Population, total_cases, (total_cases/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2


-- Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing countries with the highest death count per population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing the continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths
----WHERE location like '%states%'
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT Date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY 1, 2

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY Date
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations
-- what is the total amount of people in the world that have been vaccinated

SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS TotalPercentageVaccinated
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccincated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


SELECT *, (RollingPeopleVaccinated/Population)*100 AS TotalPercentageVaccinated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated