/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProjects..CovidDeaths
Order by 3,4


--Select *
--From PortfolioProjects..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
Where continent is not null
Order by 1,2

-- Total cases vs total deaths
-- Shows likelihood of death if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%India' and
continent is not null
Order by 1,2


-- Total cases vs population
-- shows what percentage of population got infected with covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%India'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%India' and continent is not Null
Group By location, population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%India' and continent is not Null
Where continent is not null
Group By location
Order by TotalDeathCount desc

-- Breaking things down by continent
-- showing continets with highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%India' 
Where continent is not null
Group By continent
Order by TotalDeathCount desc

-- Global numbers

Select  Max(new_cases) as Total_cases, Max(cast(new_deaths as int)) as TotalDeaths, Max(cast(new_deaths as int))/Max(new_cases)*100 as Deathpercentage
From PortfolioProjects..CovidDeaths
--Where location like '%India' 
Where continent is not null
--Group By date
Order by 1,2

-- Total Population vs Vaccinations
-- Shows percentage of population that has received at least one Covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/dea.population) * 100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/dea.population) * 100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)

Select *, (RollingpeopleVaccinated/Population) * 100
From PopvsVac


-- Using Temp Table to perform calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/dea.population) * 100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingpeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


-- Creating View to store data

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


