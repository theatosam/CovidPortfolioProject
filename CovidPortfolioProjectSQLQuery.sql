SELECT *
FROM PortfolioProject..CovidDeaths
--WHERE continent is not null
ORDER BY 3, 4

-- SELECT *
-- FROM PortfolioProject..CovidVaccinations
-- ORDER BY 3, 4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal)/CAST(total_cases AS decimal)*100) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
and continent is not null
ORDER BY 1, 2

-- Looking at Total Cases vs the Population
-- Shows what percentage of the population got covid
SELECT location, date, population, total_cases, (CAST(total_cases AS decimal)/CAST(population AS decimal)*100) AS pop_percentage
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rates compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS decimal)/CAST(population AS decimal))*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc

-- LET'S BREAK IT DOWN BY CONTINENT
-- Showing continents with the Highest Death Counts per Population

SELECT continent, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc


-- GLOBAL NUMBERS

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
CASE WHEN sum(new_cases) = 0 then 0 else sum(new_deaths)/sum(new_cases)*100 end as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
--group by date
ORDER BY 1, 2

-- Looking at Total Populaion vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table
Drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualisations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated






