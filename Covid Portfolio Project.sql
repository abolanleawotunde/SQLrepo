select * 
from portfolio_23.coviddeaths
order by 3,4;

-- select * 
-- from portfolio_23.covid_vaccinations
-- order by 3,4;

-- SELECTING THE DATA WE'LL BE USING --
Select location, CDdate, total_cases, new_cases, total_deaths, population
from portfolio_23.coviddeaths
order by 1;

-- LOOKING AT THE TOTAL CASES VS TOTAL DEATHS --
Select location, CDdate, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from portfolio_23.coviddeaths
order by 1;

-- LOOKING AT THE TOTAL CASES VS TOTAL DEATHS IN A COUNTRY THAT CONTAINS 'STATES' --
Select location, CDdate, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from portfolio_23.coviddeaths
where location like '%states%'
order by 1;

-- LOOKING AT THE TOTAL CASES VS POPULATION IN THE UNITED STATES--
Select location, CDdate, total_cases, population, (total_cases/population)*100 as case_ratio
from portfolio_23.coviddeaths
where location = 'United States'
order by 1;
-- SHOWS WHAT % OF POPULATION GOT COVID

-- WHAT COUNTRIES HAVE THE HIGHEST INFECTION RATE COMPARED TO THE POPULATION --
Select location, Max(total_cases) as HighestInfectionCount, population, Max(total_cases/population)*100 as infection_rate
from portfolio_23.coviddeaths
Group by location, population
order by 4 desc,1;

-- BELOW SHOWS THE COUNTRIES WITH THE HIGHEST DEATH RATE PER POPULATION --
Select location, max(total_deaths) as TotalDeathCount
from portfolio_23.coviddeaths
Group by location
order by 2 desc;

-- BELOW SHOWS THE CONTINENTS WITH THE HIGHEST DEATH RATE PER POPULATION --
Select continent, max(total_deaths) as TotalDeathCount
from portfolio_23.coviddeaths
Group by continent
order by 2 desc;

-- Total_deaths columns seems to be stored as VARCHAR from the source, modifying table type below --
-- Alter table portfolio_23.coviddeaths
-- Modify column total_deaths int

-- GLOBAL NEW CASES --
Select  CDdate, SUM(new_cases) as totalnewcases, SUM(new_deaths) as totalnewdeaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage -- , total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from portfolio_23.coviddeaths
-- where continent is not null
group by CDdate
order by 1;

-- GLOBAL TOTAL CASES --
Select  SUM(new_cases) as totalnewcases, SUM(new_deaths) as totalnewdeaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage -- , total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from portfolio_23.coviddeaths
-- where continent is not null
order by 1;

-- Updating column name in vaccination table
Alter table portfolio_23.covid_vaccinations rename column date to vacdate;

-- JOINING TABLES --
select * 
from Portfolio_23.coviddeaths as dea
Join Portfolio_23.covid_vaccinations as vac
on dea.location = vac.location
and dea.CDdate = vac.vacdate;

-- LOOOKING AT TOTAL POPULATION VS VACCINATIONS --
select dea.continent, dea.location, dea.CDdate, dea.population, vac.new_vaccinations 
from Portfolio_23.coviddeaths as dea
Join Portfolio_23.covid_vaccinations as vac
on dea.location = vac.location
and dea.CDdate = vac.vacdate
order by 2,3;

-- USING CTES--
With vacimp (continent, location, CDdate, population, new_cases, new_vaccinations, dea_rate)
as
(
select dea.continent, dea.location, dea.CDdate, dea.population, dea.new_cases, vac.new_vaccinations, 
(dea.new_cases/dea.population)*100 as dea_rate
from Portfolio_23.coviddeaths as dea
Join Portfolio_23.covid_vaccinations as vac
on dea.location = vac.location
and dea.CDdate = vac.vacdate
)
select *, (dea_rate/new_vaccinations) * 100 as vaccination_impact
from vacimp;

-- USING TEMP TABLES--
Create temporary table percentpopulationdea 
(
continent nvarchar(200),
location nvarchar(200),
CDdate datetime,
population numeric,
new_vaccinations numeric,
dea_rate numeric
);

-- INSERTING DATA INTO TEMPTABLE
Insert into percentpopulationdea
select dea.continent, dea.location, dea.CDdate, dea.population, vac.new_vaccinations,
(dea.new_cases/dea.population)*100 as dea_rate
from Portfolio_23.coviddeaths as dea
Join Portfolio_23.covid_vaccinations as vac
on dea.location = vac.location
and dea.CDdate = vac.vacdate;

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS --
Create view covidmortalityrate as
select dea.continent, dea.location, dea.CDdate, dea.population, dea.new_cases 
(dea.new_cases/dea.population)*100 as dea_rate
from Portfolio_23.coviddeaths as dea
Join Portfolio_23.covid_vaccinations as vac
on dea.location = vac.location
and dea.CDdate = vac.vacdate;
