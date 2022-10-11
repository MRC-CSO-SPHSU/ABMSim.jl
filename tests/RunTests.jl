"""
Run this script from shell as 
# JULIA_LOAD_PATH="/path/to/LoneParentsModel.jl/src:\$JULIA_LOAD_PATH" julia RunTests.jl

or within REPL

julia> push!(LOAD_PATH,"/path/to/MultiAgents.jl")
julia> include("RunTests.jl")
"""

using Test

# agents 

using MultiAgents: initMultiAgents, verifyAgentsJLContract,  MAVERSION
using MultiAgents: kill_agent!, seed!, nagents, time
using MultiAgents: step!, errorstep, dummystep, run! 
using MultiAgents: currstep, stepnumber, dt, startTime, finishTime
using MultiAgents: DefaultFixedStepSim, AbsFixedStepSim, FixedStepSim, ABMSimulation
using MultiAgents: initFixedStepSim!               
using MultiAgents: attach_agent_step!, attach_post_model_step!, verboseStep
import MultiAgents: setup!


initMultiAgents()
@assert MAVERSION == v"0.3"

include("./datatypes.jl")

@testset "MultiAgents Components Testing" begin
    

    @testset verbose=true "AbstractAgent verification" begin

        person1 = Person("Edinbrugh",46//1)             
        person3 = Person("Abderdeen",25 + 3 // 12) 

        @test verifyAgentsJLContract(person3)
        @test verifyAgentsJLContract(Person)

        @test person1.id == 1 
        @test person3.id == 2

    end 


    @testset verbose=true "ABM functionalities validation" begin

        mutable struct PopVars 
            stepnumber :: Int 
            PopVars() = new(0)
        end

        population = ABM{Person}(t = 1980 // 1, variables = PopVars())

        createInvalidPopulation!(population)

        @test !verifyAgentsJLContract(population)

        person2 = population[1]
        kill_agent!(person2,population)
        @test verifyAgentsJLContract(population)

        @test time(population) == 1980 // 1 
        @test population[1].id == person2.id 

        kill_agent!(population[1],population)
        @test nagents(population) == 4

        @test_throws ArgumentError kill_agent!(person2,population)
        @test nagents(population) == 4

        add_agent!(person2,population) 
        @test nagents(population) == 5
 
        @test seed!(population,1) skip=true
        @test move_agent!(person2,"The Highlands",population) skip=true

    end 

    @testset verbose=true "pre-defined stepping functions of ABMs" begin

        population = ABM{Person}(t = 1980 // 1, variables = PopVars())
        createPopulation!(population)

        person1 = population[1]

        @test dummystep(population) == nothing 
        @test dummystep(person1, population) == nothing 

        @test_throws ErrorException errorstep(population) 

    end 

    stepsize(population::ABM{Person}) = 1 // 12 

    age_step!(person::Person,model::ABM{Person},
                sim::AbsFixedStepSim=DefaultFixedStepSim()) = 
        person.age += stepsize(model)
    
    function population_step!(population::ABM{Person}) 
        population.t += stepsize(population)
        population.variables.stepnumber += 1
        nothing 
    end

    function age_step!(population::ABM{Person})
        
        agents = allagents(population) 
        for person in agents 
            age_step!(person,population)
        end
        population_step!(population)

    end 

    prestep!(pop::ABM{Person}) = pop.t += stepsize(pop)  
    poststep!(pop::ABM{Person}) = pop.variables.stepnumber += 1

    @testset verbose=true "self-defined stepping functions for ABMs" begin 

        population = ABM{Person}(t = 1980 // 1, variables = PopVars())
        createPopulation!(population)
        
        person1 = population[1]
        age_step!(person1,population) 
        @test person1.age > 46 

        person6 = population[5]
        age_step!(population)
        @test person6.age == 29 + 6 // 12 

        year,month = date2YearsMonths(time(population))
        month += 1  # adjust 
        @test month == 2
        @test population.variables.stepnumber == 1 

        step!(population,age_step!,n=12) 
        @test person1.age > 47 && person6.age > 30
        year,month = date2YearsMonths(time(population))
        month += 1  # adjust 
        @test month == 2
        @test year == 1980 
        @test population.variables.stepnumber == 1 
        
        step!(population,age_step!,population_step!,n=12)
        @test person1.age > 48 && person6.age > 31
        year,month = date2YearsMonths(time(population))
        month += 1  # adjust 
        @test month == 2
        @test year == 1981 
        @test population.variables.stepnumber == 13 

        step!(population,dummystep,age_step!,dummystep,n=12)
        @test person1.age > 49 && person6.age > 32
        year,month = date2YearsMonths(time(population))
        month += 1  # adjust 
        @test month == 2
        @test year == 1981 
        @test population.variables.stepnumber == 13 
        
    end 

       
    @testset verbose=true "Simulating an ABM with a simple simulator" begin 

        pop = ABM{Person}(t = 1980 // 1)
        createPopulation!(pop)

        simulator = FixedStepSim(dt=1//12,
                                startTime=time(pop),finishTime=1990,
                                verbose=false)

        @test currstep(simulator) == 1980 // 1 
        @test dt(simulator) == 1 // 12 
        @test stepnumber(simulator) == 0 
        @test time(pop) == 1980 // 1 

        step!(pop,age_step!,dummystep,simulator)

        @test time(pop) > 1980 
        @test currstep(simulator) == time(pop) 
        @test stepnumber(simulator) == 1 

        run!(pop,age_step!,dummystep,simulator)

        @test time(pop) == 1990 
        @test currstep(simulator) == time(pop) 
        @test stepnumber(simulator) == 120

        initFixedStepSim!(simulator, dt= 1 // 12, 
                                    startTime = 1990 + 1//12,
                                    finishTime = 2000) 

        @test_throws ArgumentError run!(pop,dummystep,age_step!,dummystep,simulator) 

        initFixedStepSim!(simulator, dt= 1 // 12, 
                            startTime = 1990,
                            finishTime = 2000) 

        # pop.t = currstep(simulator)

        @test currstep(simulator) == 1990 
        @test dt(simulator) == 1 // 12 
        @test stepnumber(simulator) == 0 
        @test time(pop) == 1990  
                                
        run!(pop,dummystep,age_step!,dummystep,simulator) 

        @test time(pop) == finishTime(simulator) 
        @test currstep(simulator) == time(pop) 
        @test stepnumber(simulator) == 120

    end

    incomeChange!(person::Person,pop::ABM{Person},::ABMSimulation) =  
        person.income += ( rand() - 0.5 ) * 2 * pop.parameters.changeModifier * person.income
    
    age_step!(person::Person,pop::ABM{Person},sim::ABMSimulation) = 
        person.age += dt(sim)

    function incomeAvg!(pop::ABM{Person},sim::ABMSimulation) 
        ret = 0
        for person in allagents(pop)
            ret += person.income 
        end
        pop.variables.averageIncome = ret / nagents(pop)
        verboseStep(pop.variables.averageIncome,"average income",sim)  
        nothing 
    end 


    @testset verbose=true "Simulation ABM with an ABM Simulation type" begin 

        struct IncomePars
            changeModifier::Float64
        end 
    
        mutable struct IncomeVar 
            averageIncome::Float64 
        end 
    
        popWincome = ABM{Person}(t = 1980 // 1,
                            parameters = IncomePars(0.01), 
                            variables = IncomeVar(0))
        createPopulation!(popWincome)

        @test_throws Exception  abmsim = 
                ABMSimulation( dt=1//12,
                                startTime=time(popWincome), finishTime=1990,
                                verbose=false, yearly=true) 

        abmsim = ABMSimulation( dt=1//12,
                                startTime=time(popWincome), finishTime=1990,
                                verbose=false, yearly=true, 
                                setupEnabled = false) 

        @test currstep(abmsim) == 1980 // 1 
        @test dt(abmsim) == 1 // 12 
        @test stepnumber(abmsim) == 0 
        @test time(popWincome) == 1980 // 1
        @test nagents(popWincome) > 0 

        attach_agent_step!(abmsim,age_step!)
        attach_agent_step!(abmsim,incomeChange!)
        attach_post_model_step!(abmsim,incomeAvg!)

        step!(popWincome,abmsim)

        @test currstep(abmsim) > 1980 // 1 
        @test stepnumber(abmsim) == 1 
        @test time(popWincome) == currstep(abmsim) 

        run!(popWincome,abmsim)
        
        @test currstep(abmsim) == 1990 // 1 + 1 // 12
        @test stepnumber(abmsim) == 121
        @test time(popWincome) == currstep(abmsim) 
        @test popWincome.variables.averageIncome != 10000.0

    end

    @testset verbose=true "Testing a MultiABM basic functionalities " begin 

        demography = Demography()

        @test nagents(demography) == 5
        @test time(demography) == time(demography.pop)
        @test demography[1].id == 1

        person6 = Person(6,"Highlands",36//1) 
        add_agent!(demography,person6)
        @test demography[6].id == 6            
        @test nagents(demography) == 6

        kill_agent!(person6,demography)
        @test nagents(demography) == 5

    end 

    age_step!(person::Person,demography::Demography,
        sim::AbsFixedStepSim = DefaultFixedStepSim()) = 
            age_step!(person,demography.pop)
    
    incomeGain(person::Person,::Demography) = 
        person.income += rand(1000.0,2000.0)

    function stock_step!(demography::Demography) 

        demography.pop.t += stepsize(demography.pop)

        for share in allagents(demography.shares) 
            share.price += rand(1:10) * share.pos / 100 * rand([-1 1])     
        end 
        demography.shares.t = time(demography.pop) 

        nothing 
    end

    @testset verbose=true "Executing A MultiABM in an Agent.jl-way" begin 

        demography = Demography()

        step!(demography,age_step!) 

        @test time(demography) == 1980 

        @test demography[1].age > 46

        pr = demography.shares[1].price 

        step!(demography,age_step!,stock_step!)

        @test demography.shares[1].price != pr

    end 

    #age_step!(person::Person,demography::Demography,sim::FixedStepSim) = 
    #    age_step!(person,mainabm(demography),sim) 

    function stock_step!(demography::Demography,sim::FixedStepSim) 

        if sim.stepnumber % 12 != 0 return nothing end 

        demography.shares.t += 1 // 1 

        for share in allagents(demography.shares) 
            share.price += rand(1:10) * share.pos / 100 * rand([-1 1])     
        end 

        nothing 
    end
    
    @testset verbose=true "Simulating an MultiABM with a simple simulator" begin 

        demography = Demography()

        simulator = FixedStepSim(dt=1//12,
                                    startTime=time(demography),
                                    finishTime=time(demography)+10,
                                    verbose = false )
        
        share1 = demography.shares[1]
        price = share1.price

        @test currstep(simulator) == 1980 // 1 
        @test dt(simulator) == 1 // 12 
        @test stepnumber(simulator) == 0 
        @test time(demography) == 1980 // 1 
        
        step!(demography,age_step!,stock_step!,simulator)
                            
        @test time(demography) > 1980 
        @test time(demography.pop) == 1980 + 1 // 12
        @test currstep(simulator) == time(demography) 
        @test stepnumber(simulator) == 1 
        @test share1.price == price 
        @test time(demography.shares) == 0

        run!(demography,age_step!,stock_step!,simulator)
                            
        @test time(demography) == 1990 == currstep(simulator)
        @test stepnumber(simulator) == 120 
        @test share1.price != price 
        @test time(demography.shares) == 10

        initFixedStepSim!(simulator, dt= 1 // 12, 
                            startTime = 1990 + 1 // 12,
                            finishTime = 2000,
                            verbose = false ) 
                            
        @test_throws ArgumentError run!(demography,dummystep,age_step!,dummystep,simulator) 
        
        initFixedStepSim!(simulator, dt= 1 // 12, 
                            startTime = 1990 ,
                            finishTime = 2000 , 
                            verbose = false) 

        run!(demography,dummystep,age_step!,dummystep,simulator) 
                            
        @test time(demography) == finishTime(simulator) == currstep(simulator)
        @test stepnumber(simulator) == 120

    end 


end  # testset MultiAgents components 

nothing