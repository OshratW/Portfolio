SELECT *
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM SQL_FIRST_PROJECT..CovidVaccinations
--ORDER BY 3,4

--Select Data that I'm going to use

SELECT location, date, total_cases, new_cases, new_deaths, population
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--Using Rolling numbers to calculate the adding deaths every day for every Location (useful if we didn't have column "total_deaths")

SELECT location, date, total_cases, new_cases, new_deaths, SUM(CONVERT(bigint,new_deaths)) OVER (Partition by Location order by date) as RollingDeaths, population
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

--USE CTE

WITH CASEvsDEA (location, date, total_cases, new_cases, new_deaths, RollingDeaths, population)
AS
(SELECT location, date, total_cases, new_cases, new_deaths, SUM(CONVERT(bigint,new_deaths)) OVER (Partition by Location order by date) as RollingDeaths, population
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not NULL
--ORDER BY 1,2
)
SELECT *, (RollingDeaths/total_cases)*100
FROM CASEvsDEA



--Looking at Total Cases vs Total Deaths
--Shows the liklihood of dying from covid in DK (Using the total_deaths column)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE location= 'Denmark'
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of the population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE location= 'Denmark'
ORDER BY 1,2

--Creating a Temp table #PercentPopulationDeaths


Drop table if exists PercentPopulationDeaths
Create table PercentPopulationDeaths
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Total_cases numeric,
PercentPopulationInfected numeric
)
Insert into PercentPopulationDeaths
SELECT continent, location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM SQL_FIRST_PROJECT..CovidDeaths
--WHERE location= 'Denmark'
ORDER BY 1,2

Select *
FROM PercentPopulationDeaths

--Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases)/population)*100 as PercentPopulationInfected
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not NULL
Group by location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Cases per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not NULL
Group by location
Order by TotalDeathCount DESC

--Breaking it up by Continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not NULL
Group by continent
Order by TotalDeathCount DESC

--Continents with Highest Deaths per Population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not NULL
Group by continent
Order by TotalDeathCount DESC

--GLOBAL NUMBERS

--New Cases by Date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Percentage of Death from getting Covid

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Exploring CovidVaccinations table


SELECT *
FROM SQL_FIRST_PROJECT..CovidVaccinations

--Joining the two tables on location and date

SELECT *
FROM SQL_FIRST_PROJECT..CovidDeaths dea
JOIN SQL_FIRST_PROJECT..CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location

--Looking at Total population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM SQL_FIRST_PROJECT..CovidDeaths dea
JOIN SQL_FIRST_PROJECT..CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location
WHERE dea.continent is not null
order by 2,3

-- Total vaccinations per location

ALTER TABLE SQL_FIRST_PROJECT..CovidVaccinations ALTER COLUMN new_vaccinations nvarchar(150)

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location) as TotalVaccinations
FROM SQL_FIRST_PROJECT..CovidDeaths dea
JOIN SQL_FIRST_PROJECT..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is not null
order by 2,3


--Looking at Max numbers of vaccinations per country

--Use CTE

WITH POPvsVAC (continent, location, population, totalvaccinations)
as
(
SELECT dea.continent, dea.location, dea.population,
SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location) as TotalVaccinations
FROM SQL_FIRST_PROJECT..CovidDeaths dea
JOIN SQL_FIRST_PROJECT..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is not null
--order by 2,3
)
SELECT *
FROM POPvsVAC


--Creating views to store data for later visualizations

Use SQL_FIRST_PROJECT 
GO
Create view TotalVaccinations as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location) as TotalVaccinations
FROM SQL_FIRST_PROJECT..CovidDeaths dea
JOIN SQL_FIRST_PROJECT..CovidVaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
WHERE dea.continent is not null
--order by 2,3

--VIEW OF Percentage of Death from getting Covid

USE SQL_FIRST_PROJECT
GO
CREATE VIEW DeathPercentage as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM SQL_FIRST_PROJECT..CovidDeaths
WHERE continent is not null
--ORDER BY 1,2

SELECT *
FROM DeathPercentage












