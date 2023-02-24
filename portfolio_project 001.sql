select *
from PortfolioProject..CovidDeaths 
ORDER BY 3,4

select *
from PortfolioProject..CovidVaccinations
order by 1,2




-- select the data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths 
--show what percentage of the infected population died of covid
-- you can check for specific locations using the where clause


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2

--looking at the total cases vs the population
-- show what percentage of the population got covid

select location, date, population, total_cases,  (total_cases/population)*100 AS IinfectionPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate conpared to populaltion 

select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS IinfectionPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by IinfectionPercentage desc

--showing the countries with the highest death count per population

select location, max(total_deaths) AS TotalDeathsCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location
order by TotalDeathsCount desc



-- the totaldeaths column in the query above was set as 'varchar' hence needs to be changed to int using the 'cast' function

select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathsCount desc


select location, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathsCount desc


select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc

-- showing the continent with the highest deathcount per population

select continent, max(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathsCount desc


-- Global Numbers

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 4 desc

-- Looking at total population vs vaccinations

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations 
from PortfolioProject..CovidDeathS AS dea join PortfolioProject..CovidVaccinations as vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- to create a new colum showing the new vaccinations summations per location. we will use the partition clause 

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as SummationPeopleVaccinated
from PortfolioProject..CovidDeathS AS dea join PortfolioProject..CovidVaccinations as vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- we need to use the newly created coumn "SummationPeopleVaccinated" for some computations. However it cannot be use except we create a CTE or a temp table 
--[USE CTE] :The want to know the percentage of the total population per location that has been vaccinated {using the SummationPeopleVaccinated column through creation of CTE}

with popVSvacc (continent, location, date, population, new_vaccinations, SummationPeopleVaccinated)
AS
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as SummationPeopleVaccinated
from PortfolioProject..CovidDeathS AS dea join PortfolioProject..CovidVaccinations as vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

-- applying the above created CTE to the querry in the 'select' statement

select *, round((SummationPeopleVaccinated/population)*100,4) AS PercentageVaccinated --rounded to 4 decimal places
from popVSvacc

-- USING Temp TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
New_vaccination numeric,
SummationPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as SummationPeopleVaccinated
from PortfolioProject..CovidDeathS AS dea join PortfolioProject..CovidVaccinations as vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (SummationPeopleVaccinated/population)*100 AS PercentageVaccinated --rounded to 4 decimal places
from #PercentagePopulationVaccinated


-- Creating View to store data for later visualizations

create view PercentagePopulationVaccinated2
as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as SummationPeopleVaccinated
from PortfolioProject..CovidDeathS AS dea JOIN PortfolioProject..CovidVaccinations as vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
