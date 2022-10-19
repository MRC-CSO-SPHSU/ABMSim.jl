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
using MultiAgents: kill_agent!, seed!, nagents
using MultiAgents: step!, errorstep, dummystep, run! 
using MultiAgents: currstep, stepnumber, dt, startTime, finishTime, verbose
using MultiAgents: DefaultFixedStepSim, AbsFixedStepSim, FixedStepSim, ABMSimulation
using MultiAgents: initFixedStepSim!               
using MultiAgents: attach_agent_step!, attach_post_model_step!, verboseStep


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
            time :: Rational{Int}
            PopVars(t) = new(0,t)
        end

        population = ABM{Person}(variables = PopVars(1980 // 1))

        createInvalidPopulation!(population)

        @test !verifyAgentsJLContract(population)

        person2 = population[1]
        kill_agent!(person2,population)
        @test verifyAgentsJLContract(population)

        @test population[1].id == person2.id 

        kill_agent!(population[1],population)
        @test nagents(population) == 4

        @test_throws ArgumentError kill_agent!(person2,population)
        @test nagents(population) == 4

        add_agent!(person2,population) 
        @test nagents(population) == 5
 
        @test move_agent!(person2,"The Highlands",population) skip=true

    end 

    @testset verbose=true "pre-defined stepping functions of ABMs" begin

        population = ABM{Person}(variables = PopVars(1980 // 1))
        createPopulation!(population)

        person1 = population[1]

        @test dummystep(population) == nothing 
        @test dummystep(person1, population) == nothing 

        @test_throws ErrorException errorstep(population) 

    end 

    stepsize(population::ABM{Person}) = 1 // 12 

    age_step!(person::Person,model::ABM{Person};
                simulator::AbsFixedStepSim = DefaultFixedStepSim()) = 
        person.age += stepsize(model)
    
    function population_step!(population::ABM{Person}) 
        population.variables.time += stepsize(population)
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

    prestep!(pop::ABM{Person}) = pop.variables.time += stepsize(pop)  
    poststep!(pop::ABM{Person}) = pop.variables.stepnumber += 1

    @testset verbose=true "self-defined stepping functions for ABMs" begin 

        population = ABM{Person}(variables = PopVars(1980 // 1))
        createPopulation!(population)
        
        person1 = population[1]
        age_step!(person1,population) 
        @test person1.age > 46 

        person6 = population[5]
        age_step!(population)
        @test person6.age == 29 + 6 // 12 

        year,month = date2YearsMonths(population.variables.time)
        month += 1  # adjust 
        @test month == 2
        @test population.variables.stepnumber == 1 

        step!(population,age_step!,n=12) 
        @test person1.age > 47 && person6.age > 30
        year,month = date2YearsMonths(population.variables.time)
        month += 1  # adjust 
        @test month == 2
        @test year == 1980 
        @test population.variables.stepnumber == 1 
        
        step!(population,age_step!,population_step!,n=12)
        @test person1.age > 48 && person6.age > 31
        year,month = date2YearsMonths(population.variables.time)
        month += 1  # adjust 
        @test month == 2
        @test year == 1981 
        @test population.variables.stepnumber == 13 

        step!(population,dummystep,age_step!,dummystep,n=12)
        @test person1.age > 49 && person6.age > 32
        year,month = date2YearsMonths(population.variables.time)
        month += 1  # adjust 
        @test month == 2
        @test year == 1981 
        @test population.variables.stepnumber == 13 
        
    end 
  
    @testset verbose=true "Simulating an ABM with a simple simulator" begin 

        pop = ABM{Person}()
        createPopulation!(pop)

        simulator2 = FixedStepSim(dt=1//12,
                                startTime=1981,finishTime=1991,
                                verbose=false)

        mutable struct SimPars1 
            startTime
            dummy 
            SimPars1() = new(1980,false)
        end 

        @test_throws ArgumentError initFixedStepSim!(simulator2,SimPars1())

        mutable struct SimPars2 
            dt
            startTime
            finishTime 
            SimPars2() = new(1//12,1980,1990)
        end 

        initFixedStepSim!(simulator2,SimPars2())
        
        simulator = FixedStepSim(SimPars2())

        @test currstep(simulator2) == 1980 // 1 == currstep(simulator)
        @test dt(simulator2) == 1 // 12 == dt(simulator)
        @test stepnumber(simulator2) == 0 == stepnumber(simulator)  

        step!(pop,age_step!,dummystep,simulator=simulator)

        @test currstep(simulator) > 1980 
        @test stepnumber(simulator) == 1 

        run!(pop,age_step!,dummystep,simulator=simulator)

        @test currstep(simulator)  == 1990 
        @test stepnumber(simulator) == 120

        initFixedStepSim!(simulator, dt= 1 // 12, 
                            startTime = 1990,
                            finishTime = 2000) 

        @test currstep(simulator) == 1990 
        @test dt(simulator) == 1 // 12 
        @test stepnumber(simulator) == 0 
                                
        run!(pop,dummystep,age_step!,dummystep,simulator=simulator) 

        @test currstep(simulator) == finishTime(simulator) 
        @test stepnumber(simulator) == 120

    end

    incomeChange!(person::Person,pop::ABM{Person}; 
                simulator::ABMSimulation) =  
        person.income += ( rand() - 0.5 ) * 2 * pop.parameters.changeModifier * person.income
    
    age_step!(person::Person,pop::ABM{Person};
            simulator::ABMSimulation) = 
        person.age += dt(simulator)

    function incomeAvg!(pop::ABM{Person};simulator::ABMSimulation) 
        ret = 0
        for person in allagents(pop)
            ret += person.income 
        end
        pop.variables.averageIncome = ret / nagents(pop)
        verboseStep(pop.variables.averageIncome,"average income",simulator)  
        nothing 
    end 


    @testset verbose=true "Simulating an ABM with an ABM Simulation type" begin 

        struct IncomePars
            changeModifier::Float64
        end 
    
        mutable struct IncomeVar 
            averageIncome::Float64 
        end 
    
        popWincome = ABM{Person}(parameters = IncomePars(0.01), 
                                    variables = IncomeVar(0))
        createPopulation!(popWincome)

        @test_throws Exception  abmsim = 
                ABMSimulation( dt=1//12,
                                startTime=1980, finishTime=1990,
                                verbose=false, yearly=true) 

        abmsim = ABMSimulation( dt=1//12,
                                startTime=1980, finishTime=1990,
                                verbose=false, yearly=true, 
                                setupEnabled = false) 

        @test currstep(abmsim) == 1980 // 1 
        @test dt(abmsim) == 1 // 12 
        @test stepnumber(abmsim) == 0 
        @test nagents(popWincome) > 0 

        attach_agent_step!(abmsim,age_step!)
        attach_agent_step!(abmsim,incomeChange!)
        attach_post_model_step!(abmsim,incomeAvg!)

        step!(popWincome,simulator=abmsim)

        @test  currstep(abmsim) > 1980 // 1 
        @test stepnumber(abmsim) == 1 

        run!(popWincome,simulator=abmsim)
        
        @test currstep(abmsim) == 1990 // 1 
        @test stepnumber(abmsim) == 120

    end


    @testset verbose=true "Testing a MultiABM basic functionalities " begin 

        demography = Demography()

        @test nagents(demography) == 5
        @test demography[1].id == 1

        person6 = Person(6,"Highlands",36//1) 
        add_agent!(demography,person6)
        @test demography[6].id == 6            
        @test nagents(demography) == 6

        kill_agent!(person6,demography)
        @test nagents(demography) == 5

    end 

    age_step!(person::Person,
                demography::Demography) = 
                    age_step!(person,demography.pop,simulator=DefaultFixedStepSim())

    function stock_step!(demography::Demography;
                            simulator::AbsFixedStepSim = DefaultFixedStepSim()) 

        for share in allagents(demography.shares) 
            share.price += rand(1:10) * share.pos / 100 * rand([-1 1])     
        end 

        nothing 
    end


    @testset verbose=true "Simulating A MultiABM in an Agent.jl-way" begin 

        demography = Demography()

        step!(demography,age_step!) 

        @test demography[1].age > 46

        pr = demography.shares[1].price 

        step!(demography,age_step!,stock_step!)

        @test demography.shares[1].price != pr

    end 
#=
    function stock_step!(demography::Demography,sim::AbsFixedStepSim) 

        if sim.stepnumber % 12 != 0 return nothing end 

        for share in allagents(demography.shares) 
            share.price += rand(1:10) * share.pos / 100 * rand([-1 1])     
        end 

        nothing 
    end


    @testset verbose=true "Simulating a MultiABM with a simple simulator" begin 

        demography = Demography()

        simulator = FixedStepSim(dt=1//12,
                                    startTime=1980,
                                    finishTime=1980+10,
                                    verbose = false )
        
        share1 = demography.shares[1]
        price = share1.price

        @test currstep(simulator) == 1980 // 1 
        @test dt(simulator) == 1 // 12 
        @test stepnumber(simulator) == 0 
        
        step!(demography,age_step!,stock_step!,simulator)
                            
        @test currstep(simulator) == 1980 + 1 // 12
        @test stepnumber(simulator) == 1 
        @test share1.price == price 

        step!(demography,age_step!,stock_step!,simulator,n=11)

        run!(demography,age_step!,stock_step!,simulator)
                            
        @test 1990 == currstep(simulator)
        @test stepnumber(simulator) == 120 
        @test share1.price != price 
        
        initFixedStepSim!(simulator, dt= 1 // 12, 
                            startTime = 1990 ,
                            finishTime = 2000 , 
                            verbose = false) 

        run!(demography,dummystep,age_step!,stock_step!,simulator) 
                            
        @test finishTime(simulator) == currstep(simulator)
        @test stepnumber(simulator) == 120

    end 


    incomeGain!(person::Person,::Demography,
                sim::AbsFixedStepSim = DefaultFixedStepSim()) = 
                    person.income += ( rand() + 1 ) * 1000
    
    function buyStocks!(demography::Demography,sim::ABMSimulation) 
        
        for person in allagents(demography) 
            if person.income > 10000
                share = demography.shares[person.id]
                qu = trunc(Int, person.income / share.price ) 
                share.quantity += qu    
                person.income -= qu * share.price
                if verbose(sim)
                    totalIncome = person.income + share.quantity * share.price 
                    println("person $(person.id): income: $(person.income) / qu: $(share.quantity) / pr: $(share.price) / risk : $(share.pos) = $(totalIncome) ")
                end 
            end
        end

        nothing 
    end
    

    @testset verbose=true "Simulating a MultiABM with an ABM Simulator" begin
    
        demography = Demography()  

        @test_throws ErrorException  abmsim = 
                ABMSimulation( dt=1//12,
                                startTime=1980, 
                                finishTime=1980+10,
                                verbose=false, yearly=true) 

        abmsim = ABMSimulation( dt=1//12, startTime=1980, 
                                            finishTime=1980+10,
                                            verbose=false, yearly=true,
                                            setupEnabled = false) 
        
        @test currstep(abmsim) == 1980 // 1

        attach_post_model_step!(abmsim,stock_step!)
        attach_agent_step!(abmsim,age_step!)
        attach_agent_step!(abmsim,incomeGain!)
        attach_post_model_step!(abmsim,buyStocks!)

        person1 = demography[1]
        income1 = person1.income 
        share1 = demography.shares[1]
        price1 = share1.price 
        quantity1 = share1.quantity 

        step!(demography,abmsim)

        @test currstep(abmsim) > 1980 // 1 
        @test stepnumber(abmsim) == 1 
        @test income1 != person1.income 

        step!(demography,abmsim, n = 12)

        @test currstep(abmsim) > 1980 // 1 
        @test stepnumber(abmsim) == 13
        @test price1 != share1.price 
        @test quantity1 != share1.quantity
        
        run!(demography,abmsim)
        @test currstep(abmsim) == finishTime(abmsim) ==
                startTime(abmsim)+10 
        @test stepnumber(abmsim) == 120 
    end 
=# 
end  # testset MultiAgents components 

nothing