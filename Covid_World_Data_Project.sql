select *
from PortfolioProjects.dbo.[Covid Deaths]
Where continent is not null
order by 3,4

--select *
--from PortfolioProjects.dbo.[Covid Vacinations]
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects.dbo.[Covid Deaths]
order by 1,2

-- Looking at total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects.dbo.[Covid Deaths]
Where Location like '%states'
order by 1,2

--Looking at the total cases vs the population
--shows what percentage of population got covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects.dbo.[Covid Deaths]
--Where Location like '%states%'
order by 1,2

--Looking at the countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProjects.dbo.[Covid Deaths]
--Where Location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Let's break things down by continent
Select continent,  MAX(total_deaths) AS TotalDeathCount
From PortfolioProjects.dbo.[Covid Deaths]
--Where Location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Let's break things down by continent -1
Select location,  MAX(total_deaths) AS TotalDeathCount
From PortfolioProjects.dbo.[Covid Deaths]
--Where Location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc

--Showing the countries with highest death count per  population
Select Location, Population, MAX(total_deaths) AS TotalDeathCount, Max((total_deaths/population)*100) as DeathPercent
From PortfolioProjects.dbo.[Covid Deaths]
--Where Location like '%states%'
Where continent is not null
Group by Location, Population
order by TotalDeathCount desc

--Showing continents with highest death count
Select continent,  MAX(total_deaths) AS TotalDeathCount
From PortfolioProjects.dbo.[Covid Deaths]
--Where Location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects.dbo.[Covid Deaths]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.[Covid Deaths] dea
Join PortfolioProjects.dbo.[Covid Vacinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.[Covid Deaths] dea
Join PortfolioProjects.dbo.[Covid Vacinations] vac
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
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.[Covid Deaths] dea
Join PortfolioProjects.dbo.[Covid Vacinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.[Covid Deaths] dea
Join PortfolioProjects.dbo.[Covid Vacinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated