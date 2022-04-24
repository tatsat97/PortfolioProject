--select *
--from CovidDeaths

--select * from CovidDeaths

--SELECT location, date, total_cases, new_cases, total_deaths, population
--from CovidDeaths
--order by 1, 2

-- looking at total cases Vs Total deaths in a specific country
-- shows the likelihood of dying if you contracted covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from CovidDeaths
where location like '%India'
order by 1, 2

--looking at total cases vs population
-- what % of population got covid
SELECT location, date, total_cases, population, (total_cases/population) * 100 as totalCasesVsPop
from CovidDeaths
where location  = 'India'
order by 1, 2

--looking at countries with highest infection rate compared to population

SELECT location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100
as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- showing the countries with highest death count per population
SELECT Location, Max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

-- showing continents with highest death count
SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc


-- Global Numbers-> getting total_cases,total_deaths and death_percentage across the world ordered by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases))* 100 as death_percentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2

--geting above results not ordered by date
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as death_percentage
from CovidDeaths
where continent is not null
order by 1, 2


--joining the two tables
Select * 
from CovidDeaths dea
join covidVaccination vac
on dea.location = vac.location
	and dea.date = vac.date


-- looking at Total population vs vaccination
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
join covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- using cte to know % of people vaccinated
-- finding cumulative sum of the new vaccinations per day 

With PopVSVac (continent, location, date, population,new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as
RollingPeopleVaccinated
from CovidDeaths dea
join covidVaccination vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)

select *, (RollingPeopleVaccinated/ population) * 100 as percentagePeopleVaccinated  from PopVSVac




--Using TEMP Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as
RollingPeopleVaccinated
from CovidDeaths dea
join covidVaccination vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/ population) * 100 as percentagePeopleVaccinated from #PercentPopulationVaccinated


--creating  VIEW
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as
RollingPeopleVaccinated
from CovidDeaths dea
join covidVaccination vac
on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated