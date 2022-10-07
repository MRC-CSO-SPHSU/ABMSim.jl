"""
Run this script from shell as 
# JULIA_LOAD_PATH="/path/to/LoneParentsModel.jl/src:\$JULIA_LOAD_PATH" julia RunTests.jl

or within REPL

julia> push!(LOAD_PATH,"/path/to/MultiAgents.jl")
julia> include("RunTests.jl")
"""

using Test

# agents 
using MultiAgents.Util: date2YearsMonths, AbstractExample, DefaultExample
using MultiAgents: AbstractXAgent 
using MultiAgents: initMultiAgents, verifyAgentsJLContract, 
                   getIDCOUNTER, MAVERSION
using MultiAgents: ABM
using MultiAgents: add_agent!, kill_agent!, seed!, nagents, allagents, time
using MultiAgents: step!, errorstep, dummystep
using MultiAgents: currstep, stepnumber, dt, startTime, finishTime
using MultiAgents: FixedStepSim, initFixedStepSim!             
using MultiAgents: run!    
using MultiAgents: ABMSimulation
using MultiAgents: attach_agent_step!
import MultiAgents: setup!


initMultiAgents()
@assert MAVERSION == v"0.3"


@testset "MultiAgents Components Testing" begin
    
    mutable struct Person <: AbstractXAgent 
        id::Int 
        pos 
        age::Rational{Int}
        income::Float64  
        Person(position,a) = new(getIDCOUNTER(),position,a,10000.0)
    end 
    
    # List of persons 
    person1 = Person("Edinbrugh",46//1) 
    person2 = person1               
    person3 = Person("Abderdeen",25 + 3 // 12) 
    person4 = Person("Edinbrugh", 26 // 1) 
    person5 = Person("Glasgow", 25 // 1)
    person6 = Person("Edinbrugh", 29 + 5 // 12)  

    @testset verbose=true "AbstractAgent verification" begin

        @test verifyAgentsJLContract(person3)
        @test verifyAgentsJLContract(Person)

        @test person1.id == 1 
        @test person3.id == 2

    end 

    # a dummy ABM 
    mutable struct PopVars 
        stepnumber :: Int 
        PopVars() = new(0)
    end

    population = ABM{Person}(t = 1980 // 1, variables = PopVars())

    add_agent!(population,person1)
    add_agent!(population,person3)
    add_agent!(population,person2)
    add_agent!(population,person4)
    add_agent!(person5,population)
    add_agent!(person6,population) 

    @testset verbose=true "ABM functionalities validation" begin

        @test !verifyAgentsJLContract(population)
        kill_agent!(person2,population)
        @test verifyAgentsJLContract(population)

        @test time(population) == 1980 // 1 
        @test population[1] == person1 

        kill_agent!(person2,population)
        @test nagents(population) == 4

        @test_throws ArgumentError kill_agent!(person1,population)
        @test nagents(population) == 4

        add_agent!(person1,population) 
        @test nagents(population) == 5
 
        @test seed!(population,1) skip=true
        @test move_agent!(person1,"The Highlands",population) skip=true

    end 

    @testset verbose=true "pre-defined stepping functions of ABMs" begin

        @test dummystep(population) == nothing 
        @test dummystep(person1, population) == nothing 

        @test_throws ErrorException errorstep(population) 

    end 

    stepsize(population::ABM{Person}) = 1 // 12 

    age_step!(person::Person,model::ABM{Person}) = 
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

        age_step!(person1,population) 
        @test person1.age > 46 

        age_step!(population)
        @test person6.age == 29.5 
        year,month = date2YearsMonths(time(population))
        month += 1  # adjust 
        @test month == 2
        @test population.variables.stepnumber == 1 

        step!(population,age_step!,12) 
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

    pop = ABM{Person}(t = 1980 // 1)
    add_agent!(pop,person1)
    add_agent!(pop,person3)
    add_agent!(pop,person4)
    add_agent!(person5,pop)
    add_agent!(person6,pop) 

    simulator = FixedStepSim(dt=1//12,startTime=time(pop),finishTime=1990,
                                verbose=true,yearly=true)
    
    @testset verbose=true "Executing ABM with a simple simulation type" begin 

        @test currstep(simulator) == 1980 // 1 
        @test dt(simulator) == 1 // 12 
        @test stepnumber(simulator) == 0 
        @test time(pop) == 1980 // 1 

        step!(pop,age_step!,dummystep,simulator)

        @test time(pop) > 1980 
        @test currstep(simulator) == time(pop) 
        @test stepnumber(simulator) == 1 

        run!(pop,age_step!,dummystep,simulator)

        @test time(pop) == 1990 + dt(simulator)
        @test currstep(simulator) == time(pop) 
        @test stepnumber(simulator) == 121

        initFixedStepSim!(simulator, dt= 1 // 12, 
                                        startTime = 1990,
                                        finishTime = 2000) 

        # println(pop.time) 
        # println(currstep(simulator))

        @test_throws ArgumentError run!(pop,dummystep,age_step!,dummystep,simulator) 

        pop.t = currstep(simulator)

        @test currstep(simulator) == 1990 
        @test dt(simulator) == 1 // 12 
        @test stepnumber(simulator) == 0 
        @test time(pop) == 1990  
                                
        run!(pop,dummystep,age_step!,dummystep,simulator) 

        @test time(pop) == finishTime(simulator) + dt(simulator)
        @test currstep(simulator) == time(pop) 
        @test stepnumber(simulator) == 121
    end

    struct IncomePars
        changeModifier::Float64
    end 

    mutable struct IncomeVar 
        averageIncome::Float64 
    end 

    popWincome = ABM{Person}(t = 1980 // 1,
                        parameters = IncomePars(0.1), 
                        variables = IncomeVar(person1.income))    

    incomeChange!(person::Person,pop::ABM{Person}) =  
        person.income += ( rand() - 0.5 ) * 2 * pop.parameters.changeModifier
                
    @testset verbose=true "Executing ABM with an ABM Simulation type" begin 

        abmsim = ABMSimulation( dt=1//12,
                    startTime=time(popWincome), finishTime=1990,
                    verbose=true, yearly=true) 

        run!(popWincome,abmsim)

        println(popWincome) 

        
    end

end  # testset MultiAgents components 

nothing