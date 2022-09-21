--For Visualisation In Tableau
--1
-- Global Numbers 
Select SUM(New_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null 
--group by date
Order by 1,2

--2 
-- We take these out as they are not included in the above queries and want to stay consistent 
-- European Union is part of Europe 
Select location, sum(cast(new_deaths as int )) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('world','European Union', 'international')
Group by location
Order by TotalDeathCount desc

--3 
--Looking at countries with highest infection rate compared to population
Select location,  population,MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Africa%'
Where continent is not null 
Group by location, population
Order by PercentPopulationInfected desc

--4 

Select location,  population,date,MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Africa%'
Group by location, population, date
Order by PercentPopulationInfected desc
