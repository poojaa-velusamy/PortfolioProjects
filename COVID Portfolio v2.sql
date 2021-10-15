--The portfolio project focuses on establishing trends related to Covid Deaths and Covid Vaccinations around the globe. The dataset used is from from: 'https://ourworldindata.org/coronavirus'

-- Firstly, we will be loading the dataset from the CovidDeaths.csv which contains the information about location, population, new cases and death cases. 
-- All data in the table are selected and sorted by location first, followed by date.

SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- Selecting the columns that we would be focusing on later. Based on the data shown, the values of total_cases, new_cases, total_deaths and population are stored for each day. The population value is the same regardless of the date.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- The column 'DeathPercentage' shows the chances of death if an individual contracts Covid-19 in United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'DeathPercentage'
FROM PortfolioProject..CovidDeaths
WHERE LOCATION = 'United States'
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- The column 'CasePercentage' shows the percentage of cases in relative to the population. Since the WHERE clause is for the location 'India', this applies to India only.

SELECT location, date, total_cases, population, (total_cases/population)*100 AS 'CasePercentage'
FROM PortfolioProject..CovidDeaths
WHERE LOCATION = 'India'
ORDER BY 1,2

-- Ranking countries' infection rate from highest to the lowest in relative to population

SELECT location, population, MAX(total_cases) AS 'InfectionCount', MAX((total_cases/population))*100 AS 'InfectionRate'
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectionRate DESC

-- Ranking countries' death count from the highest to the lowest. Note that the original data type of total_deaths is varchar. Hence, the CAST function was used to transform it into an integer value.

SELECT location, MAX(CAST(total_deaths AS int)) AS 'DeathCount'
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY DeathCount DESC

-- Ranking continents' death count from the highest to the lowest.

SELECT location, MAX(CAST(total_deaths AS int)) AS 'DeathCount'
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY DeathCount DESC

-- Showing the global figures for Total Cases, Total Deaths and Death Percentage for each day

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS 'DeathPercentage'
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1

-- Looking at Total Population vs Vaccinations. Showing the rolling count of the vaccinations as new vaccinations are registered each day. 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_rolling_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- Showing the vaccination rate change as the rolling count of the vaccinations increase. This involves the use of a temporary table.

DROP TABLE IF exists PopvsVac2
CREATE TABLE PopvsVac2
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_rolling_vaccinations numeric
)

INSERT INTO PopvsVac2
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_rolling_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *, (total_rolling_vaccinations/population)*100 AS VaccinationRate
FROM PopvsVac2

-- Create View to store data for later visualizations

CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_rolling_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT * FROM PercentPopVaccinated 