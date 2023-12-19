Select *
From [Portfolio project].dbo.CovidDeaths

Select location,date,total_cases,new_cases,total_deaths,population
From [Portfolio project].dbo.CovidDeaths
order by 1,2
--looking at total cases vs total deaths 
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
From [Portfolio project].dbo.CovidDeaths
where location like '%Tunisia%'
order by 1,2
--totalcases vs population
Select location,date,total_cases,population,(total_cases/population)*100 as death_percentage
From [Portfolio project].dbo.CovidDeaths
--where location like '%states%'
order by 1,2
--looking at countries with highest infection rate
Select location,population,MAX(total_cases)as highestinfectionCount, Max(total_cases/population)*100 as Percentpopulationinfected
From [Portfolio project].dbo.CovidDeaths
group by location,population
order by Percentpopulationinfected desc
--showing countries with highest deathcount per population
Select location,Max(cast(total_deaths as int )) as total_death_count
From [Portfolio project].dbo.CovidDeaths
group by location
order by total_death_count desc
--showing continent with the highest death count per population
Select continent,Max(cast(total_deaths as int )) as total_death_count
From [Portfolio project].dbo.CovidDeaths
where continent is not null
group by continent
order by total_death_count desc

--Global numbers
select SUM(new_cases),sum(cast(new_deaths as int)),sum(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage 
from [Portfolio project].dbo.CovidDeaths
where continent is not null
--group by date 
order by 1,2

--looking at total population vs vaccination 

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from [Portfolio project].dbo.CovidVaccinations dea
join [Portfolio project].dbo.CovidDeaths vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,Sum(convert(int,vac.new_vaccinations))over(partition by dea.location)
from [Portfolio project].dbo.CovidVaccinations dea
join [Portfolio project].dbo.CovidDeaths vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,Sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from [Portfolio project].dbo.CovidVaccinations dea
join [Portfolio project].dbo.CovidDeaths vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With Popsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) as

(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,Sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from [Portfolio project].dbo.CovidVaccinations dea
join [Portfolio project].dbo.CovidDeaths vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from Popsvac

--Temp Table 
Create table #percentpeoplevaccinated
(continent nvarchar (255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,rollingpeoplevaccinated numeric)
insert into #percentpeoplevaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,Sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from [Portfolio project].dbo.CovidVaccinations dea
join [Portfolio project].dbo.CovidDeaths vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100
from #percentpeoplevaccinated

--create view to store for later visualisations 
CREATE VIEW percentpopulationvaccinated1 as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,Sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date)as rollingpeoplevaccinated
from [Portfolio project].dbo.CovidVaccinations dea
join [Portfolio project].dbo.CovidDeaths vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
select *
from percentpopulationvaccinated1

