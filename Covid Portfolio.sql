SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null  
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Show the probability you die in Vietnam
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)
FROM PortfolioProject..CovidDeaths$
WHERE location like '%vietn%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Show the percentage of population got Covid
SELECT Location, date, total_cases, Population, (total_deaths/Population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%Vietnam%'
ORDER BY 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
-- Where location like '%Vietnam%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Show countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Show continent with highest death count
SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2

-- Show total population vs vaccinations
With PopvsVac (Continent, Location, date, population, new_vaccinantions, rollingpeoplevaccinated)
AS
(
SELECT d.continent,d.location, d.date, d.population, v.new_vaccinations,
       SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location, d.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidVaccinations$ v
JOIN PortfolioProject..CovidDeaths$ d
   ON d.location = v.location AND d.date=v.date
WHERE d.continent is not null AND new_vaccinations is not null
--ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM PopvsVac
 
 -- TEMP TABLE

DROP TABLE IF exists 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent,d.location, d.date, d.population, v.new_vaccinations,
       SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location, d.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidVaccinations$ v
JOIN PortfolioProject..CovidDeaths$ d
   ON d.location = v.location AND d.date=v.date
WHERE d.continent is not null AND new_vaccinations is not null
--ORDER BY 2,3

SELECT *, (rollingpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated;

CREATE View PercentPopulationVaccinated AS
SELECT d.continent,d.location, d.date, d.population, v.new_vaccinations,
       SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location, d.date) AS rollingpeoplevaccinated
FROM PortfolioProject..CovidVaccinations$ v
JOIN PortfolioProject..CovidDeaths$ d
   ON d.location = v.location AND d.date=v.date
WHERE d.continent is not null AND new_vaccinations is not null
-- ORDER BY 2,3
SELECT *
FROM PercentPopulationVaccinated