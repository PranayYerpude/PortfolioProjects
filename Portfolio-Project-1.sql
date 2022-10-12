Select * 
From CovidDeaths
Where continent IS NOT NULL
order by 3,4

--Select * From CovidVaccinations
--order by 3,4

-- Select Data to use
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order By 1,2

-- Total cases vs Total Deaths to check percent of death if infected with COVID
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From CovidDeaths
Where location = 'India'
Order By 1,2

-- Total cases vs Population to check how much percent of population got infected with COVID
Select location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
From CovidDeaths
Where location = 'India'
Order By 1,2

--Countries with highest infection rate vs Populaion
Select location, population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population))*100 As PercentPopulationInfected
From CovidDeaths
Group By location, population
Order By PercentPopulationInfected Desc


-- Countries with highest Death count vs population
Select location, MAX(cast(total_deaths as int)) As TotalDeathCount
From CovidDeaths
Where continent IS NOT NULL
Group By location
Order By TotalDeathCount Desc

-- Data Exploration according to Continent
Select continent, MAX(cast(total_deaths as int)) As TotalDeathCount
From CovidDeaths
Where continent IS NOT NULL
Group By continent
Order By TotalDeathCount Desc

--Global Nuumbers
Select SUM(new_cases)As Total_Cases, SUM(CAST(new_deaths As int)) As Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 As DeathPercentage
From CovidDeaths
Where continent IS NOT NULL
--Group By date
Order By 1,2


--Total population vs Vaccinated population

-- 1.Using CTE: Because I want to use RollingPeopleVaccinated aggregate function
With PopVsVac (continent, Locatin, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select death.continent, death.location, death.date, death.population, Vaccines.new_vaccinations,
SUM(CONVERT(int, Vaccines.new_vaccinations)) Over (Partition By death.location Order By death.location, death.date) As RollingPeopleVaccinated
From CovidDeaths death
Join CovidVaccinations Vaccines
	On death.location = Vaccines.location
		and death.date = Vaccines.date
where death.continent IS NOT NULL
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 From PopVsVac

-- 2.Using Temp Table: Because I want to use RollingPeopleVaccinated aggregate function
Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(100),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, Vaccines.new_vaccinations,
SUM(CONVERT(int, Vaccines.new_vaccinations)) Over (Partition By death.location Order By death.location, death.date) As RollingPeopleVaccinated
From CovidDeaths death
Join CovidVaccinations Vaccines
	On death.location = Vaccines.location
		and death.date = Vaccines.date
where death.continent IS NOT NULL
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 From #PercentPopulationVaccinated

-- Creating views to store data for visualizations
Create View PercentPopulationVaccinated As
Select death.continent, death.location, death.date, death.population, Vaccines.new_vaccinations,
SUM(CONVERT(int, Vaccines.new_vaccinations)) Over (Partition By death.location Order By death.location, death.date) As RollingPeopleVaccinated
From CovidDeaths death
Join CovidVaccinations Vaccines
	On death.location = Vaccines.location
		and death.date = Vaccines.date
where death.continent IS NOT NULL

Select * from PercentPopulationVaccinated