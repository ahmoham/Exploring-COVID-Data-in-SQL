# COVID-19 Data Exploration

## Project Overview

This project involves the exploration and analysis of COVID-19 data, using SQL queries to derive meaningful insights from the dataset. The goal is to understand various aspects of the pandemic's impact across different countries and continents, including death rates, infection rates, and vaccination progress.

The analysis focuses on the following key areas:
- Total cases vs total deaths
- Infection rates vs population
- Death counts by population
- Global cumulative statistics
- Vaccination progress compared to population

## Dataset

The data used in this analysis comes from the **covid_deaths** and **covid_vaccinations** tables exported from the [World Health Organization](https://data.who.int/dashboards/covid19/data?n=c) (WHO). The dataset includes information about COVID-19 cases, deaths, and vaccinations across different countries and continents, with metrics such as:
- **total_cases**: The total number of COVID-19 cases.
- **new_cases**: The number of new COVID-19 cases reported for each date.
- **total_deaths**: The total number of COVID-19 deaths.
- **new_deaths**: The number of new COVID-19 deaths reported for each date.
- **population**: The population of each country or region.
- **new_vaccinations**: The number of new vaccinations administered for each date.

## SQL Code Breakdown

### 1. Basic Data Selection

```sql
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2 
```
This query selects key columns from the covid_deaths table, filtering out entries where the continent is not null. It orders the results by location and date.

## 2. Total Cases vs Total Deaths
```sql
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project..covid_deaths
WHERE location = 'Canada'
AND continent IS NOT NULL
ORDER BY 1, 2
```
This query calculates the DeathPercentage for Canada, showing the likelihood of dying if a person contracts COVID-19 in the country.

## 3. Total Cases vs Population
```sql
SELECT location, date, total_cases, population, (total_cases/population)*100 as Infected_Percentage
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2
```
This query calculates the percentage of the population infected with COVID-19 for each country, based on the total number of cases.

## 4. Countries with the Highest Infection Rate
```sql
SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Population_Infected_Percentage
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC
```
This query identifies countries with the highest infection rate relative to their population.

## 5. Countries with the Highest Death Count
```sql

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC
```
This query lists countries with the highest death count per population.

## 6. Global Statistics
```sql
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2
```
This query aggregates global data by date to show total new cases, deaths, and the global death percentage.

## 7. Total Population vs Vaccinations
```sql

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Count_Vaccinations
FROM Portfolio_Project..covid_deaths dea
JOIN Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
```
This query calculates the cumulative vaccination count (rolling total) for each country, based on vaccination data.

## 8. CTE for Vaccination Progress
```sql

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Count_Vaccinations)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Count_Vaccinations
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (Rolling_Count_Vaccinations/Population)*100
From PopvsVac
```
This query uses a Common Table Expression (CTE) to calculate the cumulative vaccination percentage relative to the population.

## 9. Temporary Table for Vaccination Progress
```sql

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
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
```
This query uses a temporary table to store the cumulative vaccination count for later analysis.

## 10. View for Future Visualizations
```sql

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
```
This query creates a view to store data on vaccination progress, which can be used for future analysis or visualizations.

## Tools and Techniques Used
- Joins: Combining data from the covid_deaths and covid_vaccinations tables.
- CTEs: For organizing and simplifying complex queries, especially for cumulative calculations.
- Temporary Tables: Used for storing intermediate results.
- Windows Functions: For calculating rolling counts of vaccinations and other aggregates.
- Aggregate Functions: SUM, MAX, etc., for calculating totals and other aggregate metrics.
- Data Type Conversions: Ensuring numeric values are cast appropriately for calculations.

## Insights and Analysis
- Death Percentage: For countries like Canada, the death percentage helps assess the severity of the pandemic.
- Infection Rate: By comparing total cases to the population, we can identify how widespread COVID-19 is in each country.
- Vaccination Progress: Using cumulative vaccination data, the project tracks how many people in each country have received a COVID-19 vaccine.

## Conclusion
This project provides an in-depth analysis of COVID-19's impact, focusing on case fatality rates, infection rates, and vaccination progress. The queries used leverage advanced SQL techniques like window functions, CTEs, and aggregate functions to provide a clear picture of the pandemic’s effects across the globe.
