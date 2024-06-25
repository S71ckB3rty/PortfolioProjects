SELECT *

FROM PortfolioProject..CovidDeaths$

order by 3, 4

--Select Data I am going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
WHERE Location = 'Qatar' OR Location = 'Oman' OR Location = 'Saudi Arabia' 
OR Location = 'Kuwait' OR Location = 'United Arab Emirates' OR Location = 'Iraq' OR Location = 'Iran' OR Location = 'Bahrain'
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contracted covid in the GCC

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE Location = 'Qatar' OR Location = 'Oman' OR Location = 'Saudi Arabia' 
OR Location = 'Kuwait' OR Location = 'United Arab Emirates' OR Location = 'Iraq' OR Location = 'Iran' OR Location = 'Bahrain'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
WHERE Location = 'Qatar' OR Location = 'Oman' OR Location = 'Saudi Arabia' 
OR Location = 'Kuwait' OR Location = 'United Arab Emirates' OR Location = 'Iraq' OR Location = 'Iran' OR Location = 'Bahrain'
order by 1, 2

--Looking at GCC countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
WHERE Location = 'Qatar' OR Location = 'Oman' OR Location = 'Saudi Arabia' 
OR Location = 'Kuwait' OR Location = 'United Arab Emirates' OR Location = 'Iraq' OR Location = 'Iran' OR Location = 'Bahrain'
Group by Location, Population
order by PercentagePopulationInfected desc

-- Showing the GCC countries with the Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
WHERE Location = 'Qatar' OR Location = 'Oman' OR Location = 'Saudi Arabia' 
OR Location = 'Kuwait' OR Location = 'United Arab Emirates' OR Location = 'Iraq' OR Location = 'Iran' OR Location = 'Bahrain'
Group by Location
order by TotalDeathCount desc

-- Comparing New Case vs New Deaths in the GCC

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE Location = 'Qatar' OR Location = 'Oman' OR Location = 'Saudi Arabia' 
OR Location = 'Kuwait' OR Location = 'United Arab Emirates' OR Location = 'Iraq' OR Location = 'Iran' OR Location = 'Bahrain'
Group by date
order by 1, 2

-- Looking at GCC Populations vs Vaccinations
Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Qatar' OR dea.location = 'Oman' OR dea.location = 'Saudi Arabia' 
OR dea.location = 'Kuwait' OR dea.location = 'United Arab Emirates' OR dea.location = 'Iraq' 
OR dea.location = 'Iran' OR dea.location = 'Bahrain'

order by  2, 3

-- USE CTE

with PopvsVac (Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Qatar' OR dea.location = 'Oman' OR dea.location = 'Saudi Arabia' 
OR dea.location = 'Kuwait' OR dea.location = 'United Arab Emirates' OR dea.location = 'Iraq' 
OR dea.location = 'Iran' OR dea.location = 'Bahrain'

)
Select *,
(RollingPeopleVaccinated/population)*100 as PercentOfPopulationVaccinated
From PopvsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Qatar' OR dea.location = 'Oman' OR dea.location = 'Saudi Arabia' 
OR dea.location = 'Kuwait' OR dea.location = 'United Arab Emirates' OR dea.location = 'Iraq' 
OR dea.location = 'Iran' OR dea.location = 'Bahrain'

Select *,
(RollingPeopleVaccinated/population)*100 as PercentOfPopulationVaccinated
From #PercentPopulationVaccinated

-- Creating a view to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.location = 'Qatar' OR dea.location = 'Oman' OR dea.location = 'Saudi Arabia' 
OR dea.location = 'Kuwait' OR dea.location = 'United Arab Emirates' OR dea.location = 'Iraq' 
OR dea.location = 'Iran' OR dea.location = 'Bahrain'

Select *
From PercentPopulationVaccinated