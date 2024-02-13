select location,date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by location desc, date

select distinct location 
from CovidDeaths
order by location desc


-- total cases vs total deaths
-- shows likelihood of dying if you contract covid
select total_cases, total_deaths, ((total_deaths::float/total_cases::float) * 100) as DeathPercentage
from CovidDeaths
where continent is not null
--location like '%States%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got Covid
select location,date, total_cases, population, ((total_cases::float/population::float) * 100) as PercentagePopulationInfected
from CovidDeaths
where continent is not null
order by location, date

--looking at countries at highest infection rate compared to population


--shows the countries with the highest death count per ppopulation

--looking at countries at highest infection rate compared to population
select location, max(total_deaths) as totalDeathCount
from CovidDeaths
where continent is not null
group by location
order by  totalDeathCount desc

-- break this down by continent
select continent, max(total_deaths) as totalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by  totalDeathCount desc

--Global Numbers
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)::float/sum(new_cases)::float) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by  1,2

--1
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)::float/sum(new_cases)::float) * 100 as DeathPercentage
from CovidDeaths
where continent is not null
order by  1,2

--2
select continent, sum(new_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
and continent not in ('World', 'International', 'European Union')
group by continent
order by TotalDeathCount desc

--3
select location, population, max(total_cases) as HighestInfectionRate,  MAX((total_cases::float/population::float) * 100) as PercentagePopulationInfected
from CovidDeaths
where continent is not null
group by location, population
order by PercentagePopulationInfected desc


--4
select location, population, date, max(total_cases) as HighestInfectionRate,  MAX((total_cases::float/population::float) * 100) as PercentagePopulationInfected
from CovidDeaths
where continent is not null
group by location, population, date
order by PercentagePopulationInfected desc



-- Join CovidVaccinations and CovidDeaths and see total population vs total
With PopvsVac(Continent, Location, Date, Population, new_vaccinations, rollingpeoplevaccinated)
as
(select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.date) as rollingpeoplevaccinated
from coviddeaths d, covidvaccinations v
where d.location = v.location
and d.date = v.date
and d.continent is not null)
select *, (rollingpeoplevaccinated/population) * 100 
from PopvsVac

-- temp table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date date,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric	
)

insert into PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.location, d.date) as rollingpeoplevaccinated
from coviddeaths d, covidvaccinations v
where d.location = v.location
and d.date = v.date
and d.continent is not null

select * from PercentPopulationVaccinated