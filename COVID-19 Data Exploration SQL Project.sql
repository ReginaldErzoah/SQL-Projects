-- Select Data 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Cases vs Total Deaths 
-- Shows Likelihood of dying if you have COVID in your country

SELECT Location,date,total_cases,total_deaths,TRY_CAST(total_deaths AS float) / NULLIF(TRY_CAST(total_cases AS float), 0) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE Location = 'Ghana' AND continent is not null
ORDER BY 1,2

--Total Cases vs Population
--Shows what percentage of population got COVID

SELECT Location,date,population,total_cases, CAST(total_cases AS float)/NULLIF(CAST(population AS float),0)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population

SELECT Location,population,MAX(total_cases) AS MaxTotalCases, MAX(CAST(total_cases AS float)/NULLIF(CAST(population AS float),0)*100) AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location,population
ORDER BY PercentPopulationInfected DESC

--Countries With Highest Death Count per Population

SELECT Location,population,MAX(CAST (total_deaths AS int)) AS MaxTotalDeaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location,population
ORDER BY MaxTotalDeaths DESC

--Continents with Highest DeathCounts

SELECT continent, MAX(CAST (total_deaths AS int)) AS MaxTotalDeaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY MaxTotalDeaths DESC

--Global Numbers

SELECT 
	SUM(CAST(new_cases AS int)) AS total_cases,
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS float)/NULLIF(CAST(new_cases AS float), 0))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Population Vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int )) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE 

With PopvsVac (continent,location,date,population,New_Vaccinations,RollingPeopleInfected)
AS 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleInfected / NULLIF(population, 0))*100 AS VaccinationPercentage
FROM 
PopvsVac

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
