using MultiAgents: kill_agent!, kill_agent_opt!, 
                    kill_agent_at!, kill_agent_at_opt! 

include("./datatypes.jl")

pretty_summarysize(x) = Base.format_bytes(Base.summarysize(x))

randomPerson(id) = 
    Person(id,rand(["Aberdeen","Edinbrugh","Glasgow","Highlands"]),
                            rand(0:90) + rand(0:11) // 12 )

function randomABMPopulation(N) 
    agents = Person[] 
    for i in 1:N 
        push!(agents,randomPerson(i))
    end 
    population = ABM{Person}(agents)
end

function killAndAddAgent!(pop,M,killfunc) 
    N = nagents(pop)
    agents = allagents(pop)
    for i in 1:M 
        ind = rand(1:N) 
        killfunc(agents[ind],pop) 
        add_agent!(pop,randomPerson(N+i))
    end
    nothing 
end

function killatAndAddAgent!(pop,M,killatfunc) 
    N = nagents(pop)
    agents = allagents(pop)
    for i in 1:M 
        ind = rand(1:N) 
        killatfunc(ind,pop) 
        add_agent!(pop,randomPerson(N+i))
    end
    nothing 
end

population = randomABMPopulation(10_000)

@time killAndAddAgent!(population,210_000,kill_agent!) 
@time killAndAddAgent!(population,210_000,kill_agent_opt!) 

@time killatAndAddAgent!(population,210_000,kill_agent_at!) 
@time killatAndAddAgent!(population,210_000,kill_agent_at_opt!) 

