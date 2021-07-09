Select * 
From PortfolioProject..CovidDeaths 
Where continent is not null
order by 3,4


--Select * 
--From PortfolioProject..CovidVaccinations
--Where continent is not null
--order by 3,4


-- Select Data that we are using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
-- Shows the Possibility of dying if Covid Positive
--Where location like '%india%'
Where continent is not null
order by 1,2

-- Total Cases vs Population

Select location, date, population,total_cases,(total_cases/population) * 100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Shows what percentage of population got Covid
--Where location like '%india%'
Where continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate Compared to Infection Rate Compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
group by location, population
order by PercentPopulationInfected desc


--Countries with Highest Death Count Per Population
--Need to cast it as an integer

Select location, population, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
group by location, population
order by TotalDeathCount desc


--Breaking Things down by Continent

-- Showing the Continents with the Highest Death Count

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(New_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, cast(dea.Date as datetime)) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated