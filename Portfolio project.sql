
select * from
covid_death
order by 3,4;

--- selecting the columns we will be using
select continent , location, date, population,total_cases,total_deaths
from covid_death;

--- Lets take a look at total cases vs total deaths percentage in Nigeria
	 select continent,date,location,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
	 from covid_death
	 where continent is not null
	 and location = 'Nigeria'
	 order by death_percentage desc;

	 --- Lets take a look at total cases vs population percentage 
	 --- shows what percentage of the population has covid
	 select continent,date,location,total_cases,population, (total_cases/population)*100 as death_percentage
	 from covid_death
	 where continent is not null
	-- and location = 'Nigeria'
	 order by location,date;

	 --- looking at highest infection rate compared to the population
	 --- Faeroe island has the highest number of its population infected
 select location,population, max(total_cases) as highest_infecount , max((total_cases/population))*100 as PercentPopulationInfected
 from covid_death
 group by location,population
 order by PercentPopulationInfected desc;

 --- looking at countries with the highest deathcount compared to population

  select location, max(cast(total_deaths as bigint)) as highestDeathCount 
 from covid_death
 where continent is null
 group by location
 order by highestDeathCount desc

 --- showing the highest deathcount by continent compared to it's population
 select continent, max(cast(total_deaths as int)) as maxDeath_Count
 from portfoliodb..covid_death
group by continent
 order by 2 desc;

 --- looking at the global numbers across continents selected
 --- overall total cases and overall deaths per day
 select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as overall_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
 from covid_death
 where continent is not null
 group by date 
 order by date desc;

 --- overall total cases and deaths in total
  select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as overall_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
 from covid_death
 where continent is not null;

 --- new table
select *
from covid_death as cd 
join covid_vac as cv
 on cv.date = cd.date
 and cv.location = cd.location;


 ---looking at Total population by population
 --using a CTE
 with popvac(continennt ,location,date,population,new_vaccinations,RunningTotalVaccination)
 as (
 select cd.continent, cd.location, cd.date,cd.population,cv.new_vaccinations,
 sum(cast(cv.new_vaccinations as bigint)) over(partition by cd.location order by cd.location,cd.date) as RunningTotalVaccination
 from covid_death as cd 
join covid_vac as cv
 on cv.date = cd.date
 and cv.location = cd.location
 where cd.continent is not null
 ---order by 2,3 ;
 )
 select *, (RunningTotalVaccination/population)*100 as VaccinationPercent
 from popvac;

 

