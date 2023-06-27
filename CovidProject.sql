
--SELECT *
--FROM Project1_Covid..CovidVaccinations
--ORDER BY 3,4

SELECT *
FROM Project1_Covid..CovidDeaths
Where continent is not null
ORDER BY 3,4


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project1_Covid..CovidDeaths
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths in reporting countries

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1_Covid..CovidDeaths
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1_Covid..CovidDeaths
Where location like '%states%'
ORDER BY 1,2



--Looking at Total Cases vs the Population in the United States
--Shows what percentage of population has been infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM Project1_Covid..CovidDeaths
Where location like '%states%'
ORDER BY 1,2



--Looking at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Project1_Covid..CovidDeaths
Group By Location, Population
ORDER BY PercentPopulationInfected desc


--Looking at countries with the highest death rate per infection

SELECT Location, MAX(cast (Total_Deaths as int)) as TotalDeathCount
FROM Project1_Covid..CovidDeaths
Where continent is not null
Group By Location
ORDER BY TotalDeathCount desc


--Looking at contients with the highest death count per population

SELECT Location, MAX(cast (Total_Deaths as int)) as TotalDeathCount
FROM Project1_Covid..CovidDeaths
Where continent is null
Group By Location
ORDER BY TotalDeathCount desc

SELECT Continent, MAX(cast (Total_Deaths as int)) as TotalDeathCount
FROM Project1_Covid..CovidDeaths
Where continent is not null
Group By continent
ORDER BY TotalDeathCount desc


--Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Project1_Covid..CovidDeaths
Where continent is not null
ORDER BY 1,2


SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Project1_Covid..CovidDeaths
Where continent is not null
Group By date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
FROM Project1_Covid..CovidDeaths dea
Join Project1_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


---Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vacinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
FROM Project1_Covid..CovidDeaths dea
Join Project1_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulationPercentage
From PopvsVac



--Use Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
FROM Project1_Covid..CovidDeaths dea
Join Project1_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinatedPopulationPercentage
From #PercentPopulationVaccinated


--Creating Views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
FROM Project1_Covid..CovidDeaths dea
Join Project1_Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


CREATE VIEW PercentCovidDeaths as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1_Covid..CovidDeaths



CREATE VIEW PopulationVsInfection as
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Project1_Covid..CovidDeaths
Group By Location, Population



CREATE VIEW ContinentPopulationVsDeathRate as
SELECT Location, MAX(cast (Total_Deaths as int)) as TotalDeathCount
FROM Project1_Covid..CovidDeaths
Where continent is null
Group By Location