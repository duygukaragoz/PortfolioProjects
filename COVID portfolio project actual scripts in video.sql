SELECT *
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE Continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations cv 
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location , date, total_cases , new_cases , total_deaths , population 
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE Continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths

--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE location LIKE '%Africa%' AND Continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population , (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS CasePercentage
FROM PortfolioProject.dbo.CovidDeaths cd 
--WHERE location LIKE '%Africa%'
WHERE Continent IS NOT NULL
ORDER BY 1,2


--Looking at Countries with Highes infection rate compared to Population

SELECT location, population,MAX(total_cases) as HighestInfectionCount,   MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths cd 
--WHERE location LIKE '%Africa%'
WHERE Continent IS NOT NULL
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC 

-- Showing countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE Continent IS NOT NULL
--WHERE location LIKE '%Africa%'
GROUP BY location
ORDER BY TotalDeathCount DESC 

--Let's break things down by continent


SELECT continent , MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE Continent IS NOT NULL
--WHERE location LIKE '%Africa%'
GROUP BY continent  
ORDER BY TotalDeathCount DESC 


--Showing continents with highest death count per population

SELECT continent , MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths cd 
WHERE Continent IS NOT NULL
--WHERE location LIKE '%Africa%'
GROUP BY continent  
ORDER BY TotalDeathCount DESC 

--Global Numbers


SELECT SUM(new_cases) as total_cases, SUM(Convert(Float, new_deaths)) as total_deaths, SUM(Convert(Float, new_deaths)) / SUM(new_cases) * 100  as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths cd 
--WHERE location LIKE '%Africa%' 
WHERE Continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at Total population vs Vaccination

SELECT cd.continent, cd.location , cd.date, cd.population , cv.new_vaccinations 
,SUM(CONVERT (int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
FROM PortfolioProject.dbo.CovidDeaths cd 
JOIN PortfolioProject.dbo.CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date 
WHERE cd.continent is not NULL 
ORDER BY 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT cd.continent, cd.location , cd.date, cd.population , cv.new_vaccinations 
,SUM(CONVERT (int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
FROM PortfolioProject.dbo.CovidDeaths cd 
JOIN PortfolioProject.dbo.CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date 
WHERE cd.continent is not NULL 
--ORDER BY 2,3
)
SELECT *
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location , cd.date, cd.population , cv.new_vaccinations 
,SUM(CONVERT (int, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated / population)*100
FROM PortfolioProject.dbo.CovidDeaths cd 
JOIN PortfolioProject.dbo.CovidVaccinations cv 
	ON cd.location = cv.location 
	AND cd.date = cv.date 
--WHERE cd.continent is not NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations


SELECT *
FROM PercentPopulationVaccinated




