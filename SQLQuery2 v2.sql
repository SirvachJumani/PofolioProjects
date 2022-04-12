
Select * From 
ProtfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * from 
--ProtfolioProject..CovidVaccinations
--order by 3,4

-- Select the data 

Select location, date, total_cases, new_cases, total_deaths, population
from ProtfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases Vs Total Deaths
-- lilkelihood of dying in the country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProtfolioProject..CovidDeaths
where location like '%states'
and continent is not null
order by 1,2

--Total Cases Vs Population
-- What Popluation got covid?
Select location, date, total_cases, population, (total_cases/population)*100 as GotCovidPercentage
from ProtfolioProject..CovidDeaths
where location like '%states'
and continent is not null
order by 1,2

-- Countries having highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as HighestInfectionPercentage
from ProtfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
Group by location, population
order by HighestInfectionPercentage desc

-- Countries having highest mortality per population

Select location, max(cast(Total_deaths as int)) as TotalDeathCount
from ProtfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Check mortaliy by Continent


-- Showing Continent with Highest Death Count per population
Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from ProtfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Representation as GLOBAL NUMBERS
Select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeath, sum(cast(new_deaths as int))/sum(new_cases)* 100 as 
DeathPercentage
from ProtfolioProject..CovidDeaths
--where location like '%states'
where continent is not null
--group by date
order by 1,2

-- look at total population vs vacination
-- What is the total ammount of people in the world vaccinated?

--USE CTE

with PopVsVac (Continent, Location, Date, Population, New_vaccinations, CummlativeTotalVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (bigint, vac.new_vaccinations)) over (partition by dea.Location order by 
dea.location, dea.date) as CummlativeTotalVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (CummlativeTotalVaccinated/Population)*100 as VaccinatedPercentage
from PopVsVac

-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
CummlativeTotalVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (bigint, vac.new_vaccinations)) over (partition by dea.Location order by 
dea.location, dea.date) as CummlativeTotalVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (CummlativeTotalVaccinated/Population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated


-- creating view for store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (bigint, vac.new_vaccinations)) over (partition by dea.Location order by 
dea.location, dea.date) as CummlativeTotalVaccinated
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated