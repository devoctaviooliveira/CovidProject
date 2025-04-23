select *
	from CovidProject..CovidDeaths
	where continent is not null
	order by 3, 4


-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM CovidProject..CovidDeaths
	where continent is not null
	order by 1, 2


-- Looking at Total Cases vs Total Deaths
--Show likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	FROM CovidProject..CovidDeaths
	WHERE location like '%Brazil%'
	where continent is not null
	order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
	from CovidDeaths
	where location like '%brazil%'
	and continent is not null
	order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
	from CovidDeaths
	group by location, population
	order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	from CovidDeaths
	where continent is not null
	group by location
	order by TotalDeathCount desc

	-- LET'S BREAK THINGS DOWN BY CONTINENT

	select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	from CovidDeaths
	where continent is null
	group by location
	order by TotalDeathCount desc

-- Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
	from CovidDeaths
	where continent is not null
	group by continent
	order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM
		(new_cases)*100 as DeathPercentage
	FROM CovidProject..CovidDeaths
	where continent is not null
	group by date
	order by 1, 2

-- Total cases

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	FROM CovidProject..CovidDeaths
	where continent is not null
	--group by date
	order by 1, 2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
		dea.date) as RollingPeopleVaccinated
	from CovidProject..CovidDeaths dea
	Join CovidProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	order by 2, 3

-- USE CTE

With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
		dea.date) as RollingPeopleVaccinated
	from CovidProject..CovidDeaths dea
	Join CovidProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
	from PopvsVac


-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
		dea.date) as RollingPeopleVaccinated
	from CovidProject..CovidDeaths dea
	Join CovidProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
	from #PercentPopulationVaccinated 


--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
		dea.date) as RollingPeopleVaccinated
	from CovidProject..CovidDeaths dea
	Join CovidProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null


Select *
	from PercentPopulationVaccinated