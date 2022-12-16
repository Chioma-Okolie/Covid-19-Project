select *
from [PORTFOLIO PROJECT]..['covid deaths$']
where continent is not null
order by 3,4

--select *
--from [PORTFOLIO PROJECT]..['covid vaccinations$']
--order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population
from [PORTFOLIO PROJECT]..['covid deaths$']
order by 1,2

--Looking at Total Cases vs Total Deaths

select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [PORTFOLIO PROJECT]..['covid deaths$']
where Location = 'Nigeria'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage for population got Covid

select Location, date, Population, total_cases, (total_cases/population)*100 as PopulationPercent
from [PORTFOLIO PROJECT]..['covid deaths$']
--where Location = 'Nigeria'
order by 1,2

--Looking at Countries with highest infection rate vs population

select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from [PORTFOLIO PROJECT]..['covid deaths$']
--where Location = 'Nigeria'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing countries with Highest Death count per population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [PORTFOLIO PROJECT]..['covid deaths$']
--where Location = 'Nigeria'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- BREAKING IT DOWN BY CONTINENT

--showing continents with highest death count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [PORTFOLIO PROJECT]..['covid deaths$']
--where Location = 'Nigeria'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(new_cases)*100 as DeathPercentage
from [PORTFOLIO PROJECT]..['covid deaths$']
--where Location = 'Nigeria'
where continent is not null
--Group by date
order by 1,2

--showing table from Covid Vaccination

select *
from [PORTFOLIO PROJECT]..['covid vaccinations$'] 


--Looking at Total Population vs Vaccinations

select *
--from [PORTFOLIO PROJECT]..['covid deaths$'] dea
--Join [PORTFOLIO PROJECT]..['covid vaccinations$'] vac
--	on dea.location = vac.location
--	and dea.date = vac.date

--Showing percentage of population that has recieved at least one covid vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PORTFOLIO PROJECT]..['covid deaths$'] dea
Join [PORTFOLIO PROJECT]..['covid vaccinations$'] vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null 
order by 2,3



Select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations
, MAX(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PORTFOLIO PROJECT]..['covid deaths$'] dea
Join [PORTFOLIO PROJECT]..['covid vaccinations$'] vac
		On dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Using a CTE to perform calculation by partition in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PORTFOLIO PROJECT]..['covid deaths$'] dea
Join [PORTFOLIO PROJECT]..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Using Temp table to perform calculation on Partition by in previous query


DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PORTFOLIO PROJECT]..['covid deaths$'] dea
Join [PORTFOLIO PROJECT]..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data for later visualization

Create view PercentPopulationVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PORTFOLIO PROJECT]..['covid deaths$'] dea
Join [PORTFOLIO PROJECT]..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Create view PercentPopulationsVaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PORTFOLIO PROJECT]..['covid deaths$'] dea
Join [PORTFOLIO PROJECT]..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


