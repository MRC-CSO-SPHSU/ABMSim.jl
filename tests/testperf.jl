using ABMSim: kill_agent!, kill_agent_opt!,
                    kill_agent_at!, kill_agent_at_opt!,
                    init_abmsim

include("./datatypes.jl")

using ABMSim: nagents

pretty_summarysize(x) = Base.format_bytes(Base.summarysize(x))

randomPerson() = randomPerson(getIDCOUNTER())
randomPerson(id) =
    Person(id,rand(["Aberdeen","Edinbrugh","Glasgow","Highlands"]),
                            rand(0:90) + rand(0:11) // 12 )

function randomABMPopulation(N)
    agents = Person[]
    for _ in 1:N
        push!(agents,randomPerson())
    end
    population = PopulationABM(agents)
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

init_abmsim()

# slowest version takes 1 sec. in my machine
N = 12_500
M = 200_000

population = randomABMPopulation(N)

println(" storage for population : $(pretty_summarysize(population))")

@info "kill_agent!(agent,abm)"
@time killAndAddAgent!(population,M,kill_agent!)

@info "kill_agent_opt!(agent,abm)"
@time killAndAddAgent!(population,M,kill_agent_opt!)

@info "kill_agent_at!(agent,abm)"
@time killatAndAddAgent!(population,M,kill_agent_at!)

@info "kill_agent_at_opt!(ind,abm)"
@time killatAndAddAgent!(population,M,kill_agent_at_opt!)
