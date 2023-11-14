Select * 
From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
As 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
)
Select *
From PopvsVac

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




Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths as dea
Join [Portfolio Project].dbo.CovidVaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
