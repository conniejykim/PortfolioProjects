
--Start a New Query
Select * 
	From [Portfolio Project].dbo.CovidDeaths
Order by 3,4 
Select * 
	From [Portfolio Project].dbo.CovidVaccinations
Order by 3,4 


--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
	From [Portfolio Project].dbo.CovidDeaths
Order by 1,2 


--Looking at Total Cases vs. Total Deaths
Select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_Cases),0))*100 as DeathPercentage
	FROM [Portfolio Project].dbo.CovidDeaths
Order by 1,2


--Using Where function to view the United States specifically 
Select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_Cases),0))*100 as DeathPercentage
	FROM [Portfolio Project].dbo.CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Total Cases vs. Population (what % of US got Covid)
Select Location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
	FROM [Portfolio Project].dbo.CovidDeaths
Where location like '%states%'
Order by 1,2


--Looking at Countries with highest Infection Rate
Select Location, Population, MAX(Total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
	From [Portfolio Project].dbo.CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
	From [Portfolio Project].dbo.CovidDeaths
Where continent is not null 
Group by Location 
Order by TotalDeathCount desc


--Breaking Down Highest Death Count down by Continent (Showing continents with the highest death count per population)
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
	From [Portfolio Project].dbo.CovidDeaths
Where continent is not null 
Group by continent 
Order by TotalDeathCount desc
--(not perfect, North America does not include Canada)
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
	From [Portfolio Project].dbo.CovidDeaths
Where continent is null 
Group by location
Order by TotalDeathCount desc


--Global Numbers (not including any location or continent)
	--Getting the total (across the world) Covid cases
Select date, SUM(new_cases)
	From [Portfolio Project].dbo.CovidDeaths
Where continent is not null 
Group by date
Order by 1,2
	--total of cases, total of deaths, and total DeathPercentage per day
Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(CONVERT(float,new_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
	From [Portfolio Project].dbo.CovidDeaths
Where continent is not null 
Group by date
Order by 1,2
	--total of each as of today
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
	From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Order by 1,2


--Joining the tables 
Select *
	From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date


--Looking at Total Population vs. Vaccinations - What is the total number of people in the world that has vaccinated?
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Rolling Count using SUM and CONVERT function 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Looking at total population vs. vaccinations use the MAX function - how many poeple in that country are vaccinated?
	--Using CTE 
	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, 
RollingPeopleVaccinated) 
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
)
Select *
From PopvsVac

		--Adding aggregate function to CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, 
RollingPeopleVaccinated) 
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac

	--Using a TempTable for answering "how many poeple in that country are vaccinated?"
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255), 
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric, 
)
Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating a View to store data for later visualizations 
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Select * 
	From PercentPopulationVaccinated


