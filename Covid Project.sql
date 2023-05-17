/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 2, 3

-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project..covid_deaths
WHERE location = 'Canada' 
AND continent IS NOT NULL
ORDER BY 1, 2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as Infected_Percentage
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Shows what percentage of Canada infected with Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as Infected_Percentage
FROM Portfolio_Project..covid_deaths
WHERE location = 'Canada' 
AND continent IS NOT NULL
ORDER BY 1, 2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Population_Infected_Percentage
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC


-- SORT BY CONTINENT

-- Showing continents with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..covid_deaths
WHERE continent IS NULL AND location not like '%income%'
GROUP BY location
ORDER BY 2 DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..covid_deaths
--WHERE location = 'Canada' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) as Rolling_Count_Vaccinations
--, (Rolling_Count_Vaccinations/population)*100
FROM Portfolio_Project..covid_deaths dea
JOIN Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
 

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Count_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Count_Vaccinations
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (Rolling_Count_Vaccinations/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3