--Quick glance
select *
from CovidDeaths
Order By 3,4

Select *
From CovidVaccinations
Order By 3,4

Select Location,   Convert( Varchar(10),cast([date] as date), 101) [Date], Total_Cases, New_Cases, total_deaths, Population
From [Covid Project].[dbo].[CovidDeaths]
Order By 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country

Select Location,   [Date], Total_Cases, Total_deaths, (total_deaths/total_cases)*100 as Percent_Deaths
From [Covid Project].[dbo].[CovidDeaths]
Where location like '%States%'
Order By 2


Select Location,  Convert( Varchar(10),cast([date] as date), 101) [Date], Total_Cases, Total_deaths, (total_deaths/total_cases)*100 as Percent_Deaths
From [Covid Project].[dbo].[CovidDeaths]
Order By 1,2


-- Looking at the Total Cases vs Total Population
Select Location,   [Date], population, Total_Cases,  (total_cases/population)*100 as Percent_Deaths
From [Covid Project].[dbo].[CovidDeaths]
Where location like '%States%'
Order By 2


-- Looks at the Total Cases vs Total Population
Select Location,   [Date], population, Total_Cases,  (total_cases/population)*100 as Percent_Deaths
From [Covid Project].[dbo].[CovidDeaths]
--Where location like '%States%'
Order By 1,2


-- Looks at the Countries with highest Infection Rate compared to Population
Select Location, population, Max(Total_Cases) HighestInfectionCount,  Max((total_cases/population))*100 PercentPopulationInfected
From [Covid Project].[dbo].[CovidDeaths]
--Where location like '%States%'
Group By location, population
Order By 4 Desc


-- Looks at the Countries with highest Death counts compared to Population
Select Location, population, Max(Cast(total_deaths as Int)) HighestDeathCounts,  Max((total_deaths/population))*100 PercentDeathByPopulation
From [Covid Project].[dbo].[CovidDeaths]
Where continent is not null	
Group By location, population
Order By 3 Desc

select *
from CovidDeaths
Where continent is  null	
Order By 3,4


-- Temp table to set up the calculation percentage
Drop Table if exists #TempDeathCountsByCont
Create table #TempDeathCountsByCont
(
Continent Varchar(255),
MaxPopulation numeric,
HighestDeathCounts numeric
)

Insert into #TempDeathCountsByCont
Select Continent, MAX(population), Max(Convert(int,total_deaths)) 
From [Covid Project].[dbo].[CovidDeaths]
Where continent is not null	
Group By continent
Order By 3 Desc

Select Continent, MaxPopulation, HighestDeathCounts, Format((HighestDeathCounts/MaxPopulation)*100, 'P4') PercentDeathByPopulation
From #TempDeathCountsByCont
Order By 3 Desc


-- Shows Continents with Highest death count by population
Select continent, Max(Cast(total_deaths as Int)) HighestDeathCounts
From [Covid Project].[dbo].[CovidDeaths]
Where continent is not null	
Group By continent
Order By 2 Desc

-- Breaks things down by Location
Select Location, Max(Cast(total_deaths as Int)) HighestDeathCounts
From [Covid Project].[dbo].[CovidDeaths]
Where continent is null	
Group By location
Order By 2 Desc


-- Shows Continents with Highest death count by population
Select continent, population, Max(Total_Cases) HighestInfectionCount,  Max((total_cases/population))*100 PercentPopulationInfected
From [Covid Project].[dbo].[CovidDeaths]
--Where location like '%States%'
Group By continent, population
Order By 4 Desc


-- Looks at the Countries with highest death counts compared to Population
Select continent, population, Max(Cast(total_deaths as Int)) HighestDeathCounts,  Max((total_deaths/population))*100 PercentDeathByPopulation
From [Covid Project].[dbo].[CovidDeaths]
Where continent is not null	
Group By continent, population
Order By 3 Desc


--Drill down query
Select continent, Location, population, Max(Cast(total_deaths as Int)) HighestDeathCounts,  Max((cast(total_deaths as int)/population))*100 PercentDeathByPopulation
From [Covid Project].[dbo].[CovidDeaths]
Where continent is not null	
Group By continent, Location, population
Order By 1

--Global Numbers by date
Select Date, Sum(New_Cases) TotalCases, Sum(Cast(New_Deaths as int)) TotalDeaths, (Sum(Cast(New_Deaths as int))/Sum(New_Cases))*100 as DeathPercent
from CovidDeaths
Where continent is not null
Group By Date
Order by 1,2

--Global Numbers by Location
Select Location, Sum(New_Cases) TotalCases, Sum(Cast(New_Deaths as int)) TotalDeaths, (Sum(Cast(New_Deaths as int))/Sum(New_Cases))*100 as DeathPercent
from CovidDeaths
Where continent is not null
Group By Location
Order by 1,2


--Global Numbers New Cases
Select Sum(New_Cases) TotalCases, Sum(Cast(New_Deaths as int)) TotalDeaths, (Sum(Cast(New_Deaths as int))/Sum(New_Cases))*100 as DeathPercent
from CovidDeaths
Where continent is not null
Order by 1,2

	
-- Joining CovidDeaths tbl and CovidVac tbl
Select *
From [Covid Project]..CovidDeaths dea
join [Covid Project]..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, dea.new_cases, vac.new_vaccinations, dea.new_deaths
From [Covid Project]..CovidDeaths dea
join [Covid Project]..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Looking at Total Population vs Vaccinations with running sum - cumulative counts
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_Vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) RollingVaccinations
, dea.new_cases
, Sum(Cast(dea.new_cases as int)) over (Partition by dea.location order by dea.location, dea.date) RollingNumberNewCases
, dea.new_deaths
, Sum(Cast(dea.new_deaths as int)) over (Partition by dea.location order by dea.location, dea.date) RollingNumberNewDeaths
From [Covid Project]..CovidDeaths dea
join [Covid Project]..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null and dea.location like '%states%'
Order by 2,3


-- Use CTE
With PopcsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinations, New_Cases, RollingNumberNewCases, New_Deaths, RollingNumberNewDeaths)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_Vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) RollingVaccinations
, dea.new_cases
, Sum(Cast(dea.new_cases as int)) over (Partition by dea.location order by dea.location, dea.date) RollingNumberNewCases
, dea.new_deaths
, Sum(Cast(dea.new_deaths as int)) over (Partition by dea.location order by dea.location, dea.date) RollingNumberNewDeaths
From [Covid Project]..CovidDeaths dea
join [Covid Project]..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null --and dea.location like '%states%'
Order By 2,3
)
Select *
, (RollingVaccinations/population)*100 PercentVaccinated
, (RollingNumberNewCases/Population)*100 PercentNewCases
, (RollingNumberNewDeaths/Population)*100 DeathRateByPopulation
From PopcsVac

--Temp Table
Drop Table if Exists #PopVsVac
Create Table #PopVsVac
(
Continent Varchar(255)
, Location Varchar(255)
, Date datetime
, Population numeric
, new_vaccinations numeric
, RollingVaccinations numeric
, New_Cases numeric
, RollingNumberNewCases numeric
, New_Deaths numeric
, RollingNumberNewDeaths numeric
)
Insert into #PopVsVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_Vaccinations)) over (Partition by dea.location order by dea.location, dea.date) 
, dea.new_cases
, Sum(Cast(dea.new_cases as int)) over (Partition by dea.location order by dea.location, dea.date) 
, dea.new_deaths
, Sum(Cast(dea.new_deaths as int)) over (Partition by dea.location order by dea.location, dea.date) 
From [Covid Project]..CovidDeaths dea
join [Covid Project]..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null --and dea.location like '%states%'
Order By 2,3

Select 
  Continent 
, Location 
, Date 
, Population 
, new_vaccinations 
, RollingVaccinations 
, Format((RollingVaccinations/population)*100, 'P4') PercentVaccinated
, New_Cases 
, RollingNumberNewCases 
, Format((RollingNumberNewCases/Population)*100, 'P4') PercentNewCases
, New_Deaths 
, RollingNumberNewDeaths 
, Format((RollingNumberNewDeaths/Population)*100, 'P4') DeathRateByPopulation
From #PopVsVac

-- Creating a view to store data for later Visualization
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_Vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) RollingVaccinations
, dea.new_cases
, Sum(Cast(dea.new_cases as int)) over (Partition by dea.location order by dea.location, dea.date) RollingNumberNewCases
, dea.new_deaths
, Sum(Cast(dea.new_deaths as int)) over (Partition by dea.location order by dea.location, dea.date) RollingNumberNewDeaths
From [Covid Project]..CovidDeaths dea
join [Covid Project]..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null --and dea.location like '%states%'

Select *
from PercentPopulationVaccinated
