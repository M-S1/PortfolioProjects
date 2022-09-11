select *
from PortfolioProject..CovidDeaths
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

-- select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Looking at total cases vs total deaths 
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null 
order by 1,2

-- Looking at total Cases vs Population
-- Shows what percentage of population got Covid
select location, date,  population,total_cases,  (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null 
--where location like '%Africa%'
order by 1,2

--Looking at countries with highest infection rate compared to population 
select location,  population,MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Africa%'
where continent is not null 
Group by location, population
order by PercentPopulationInfected desc

--Showing the countries with highest Death Count per Population
select location,  Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Africa%'
where continent is not null 
Group by location 
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population
select continent,  Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Africa%'
where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global Numbers 
select SUM(New_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null 
--group by date
order by 1,2

-- Looking at total population vs Vaccination 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT null
order by 2,3

-- USE Cte

with PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT null
--order by 2,3
)
select* , (RollingPeopleVaccinated/population)*100 as PopVac
from PopvsVac

--Temp Table 

DROP TABLE if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
( 
Continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
New_vaccinations float, 
RollingPeopleVaccinated numeric, 
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT null
order by 2,3
select*, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- Create view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT null
--order by 2,3


select * 
from PercentPopulationVaccinated
