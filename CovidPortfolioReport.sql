Select *
From Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From Portfolioproject..CovidVaccinations
--order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2



--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From Portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select continent ,Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as
PercentPopulationInfected
From Portfolioproject..CovidDeaths
--where location like '%states%'
Group by continent , Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population


Select continent , Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Lets Break things down by Continent

Select continent , Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc 


--Showing the continents with the Highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is  not null
Group by continent
order by TotalDeathCount desc 



-- Global Numbers 

Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date 
order by 1,2




--Looking at Total Population vs Vaccinations



Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





--Temp Table

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
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


GO
Create View pvs_PercentPopulationVaccinated as 
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3







