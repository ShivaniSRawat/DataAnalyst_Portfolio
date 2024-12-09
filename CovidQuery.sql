select *
from PortfolioProject..CovidDeaths
order by 3,4;

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4;


--select the  required columns
select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2;

--find total death percentage
select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2;

--find total percentage of population that got covid
select Location,date,total_cases,population, (total_cases/population)*100 as PercentageInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2;

--country that is infected the most
select Location,population,max(total_cases) as Infected, max((total_cases/population))*100 as PercentageInfected
from PortfolioProject..CovidDeaths
group by Location,population
order by PercentageInfected desc;


--countries with highest death count
select Location ,max(cast(total_deaths as INT)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeath desc;

--Continent wise death
select continent ,max(cast(total_deaths as INT)) as TotalDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeath desc;

--JOIN to find total vacinnation given to a population
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVac
from PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
ON
dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
order by 1,2,3;

--CTE common table exp

With PopvsVac (Continent, Location, Date, Population, Vacinnation, RollingVac)
As
(Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as TotalVac
from PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
ON
dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
)

select *, (RollingVac/Population)*100
from PopvsVac;

--Temp table
Drop table if exists #RollingVacTable;

Create Table #RollingVacTable
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
Vacinnation numeric, 
RollingVac numeric
)

Insert into #RollingVacTable
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as TotalVac
from PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
ON
dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
;

select *, (RollingVac/Population)*100
from #RollingVacTable; 

--create a view to store data for visualization

create view PercentageRollingVacinnation as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as TotalVac
from PortfolioProject..CovidDeaths dea
JOIN
PortfolioProject..CovidVaccinations vac
ON
dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
;

select * from PercentageRollingVacinnation;