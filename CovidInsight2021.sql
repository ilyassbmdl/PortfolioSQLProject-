SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM `server-181713.Covid.covidDeaths`
 order by location, date

/* shows likelihood of dying if you contract covid in your country */

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
 FROM `server-181713.Covid.covidDeaths`
 Where location like '%States%'
 order by 2 ASC

-- Looking at total Cases VS Population the percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
 FROM `server-181713.Covid.covidDeaths`
 Where location like '%States%'
 order by InfectionPercentage ASC

 --Looking at countries with highest Infection Rate compared to population
 
SELECT location, population, Max(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS TopInfectionPercentage
 FROM `server-181713.Covid.covidDeaths`
Group by location, population
order by TopInfectionPercentage DESC

--Showing countries with highest Death Count per population

SELECT location, population, Max(total_deaths) AS HighestDeathCount
FROM `server-181713.Covid.covidDeaths`
where continent is  not null
Group by location, population
order by HighestDeathCount DESC

--Showing countries with highest Death Count per population

SELECT continent,  Max(total_deaths) AS HighestDeathCount
FROM `server-181713.Covid.covidDeaths`
where continent is   not null
Group by continent
Order by HighestDeathCount DESC


--Global numbers

SELECT   SUM(total_deaths) AS Global_Deaths, SUM(total_cases) AS Global_cases, (SUM(total_deaths)/SUM(total_cases))*100 AS TopInfectionPercentage
FROM `server-181713.Covid.covidDeaths`
where continent is not null
--Group by date
---Order by HighestDeathCount DESC


--looking at Total Population vs Vaccinations
-- USE CTE



with PopVsvac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as ( select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location , dea.date) as RollingPeopleVaccinated
FROM `server-181713.Covid.covidDeaths`  dea
Join `server-181713.Covid.CovidVaccinations` vac
on dea.location = vac.location  and dea.date = vac.date
--WHERE dea.continent is not null
--order by 1,2,3
)

select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from PopVsvac

--temp table


Drop table if exists `PercentPopulationVaccinated`
CREATE TABLE `PercentPopulationVaccinated` (
  'Continent' STRING,
  'Location' STRING,
  'date' datetime,
  'Population' numeric,
  'New_vaccinations' numeric,
  'RollingPeopleVaccinated' numeric,

)
Insert into `PercentPopulationVaccinated`
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location , dea.date) as RollingPeopleVaccinated
FROM `server-181713.Covid.covidDeaths`  dea
Join `server-181713.Covid.CovidVaccinations` vac
on dea.location = vac.location  and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from PercentPopulationVaccinated
