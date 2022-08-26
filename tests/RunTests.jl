"""
Run this script from shell as 
# JULIA_LOAD_PATH="/path/to/LoneParentsModel.jl/src:\$JULIA_LOAD_PATH" julia RunTests.jl

or within REPL

julia> push!(LOAD_PATH,"/path/to/MultiAgents.jl")
julia> include("RunTests.jl")
"""

using Test

# agents 
using MultiAgents: AbstractXAgent 
using MultiAgents: initMultiAgents, verifyAgentsJLContract, 
                   getIDCOUNTER
using MultiAgents: ABM
using MultiAgents: add_agent!, kill_agent!, seed!, nagents, allagents
using MultiAgents: errorstep, dummystep
using MultiAgents: initDefaultProp!, defaultprestep!, defaultpoststep!,
                    currstep, stepnumber, dt
using MultiAgents: step!
                   

@testset "MultiAgents Components Testing" begin
    
    initMultiAgents()

    mutable struct Person <: AbstractXAgent 
        id::Int 
        pos 
        age::Rational{Int} 
        Person(position,a) = new(getIDCOUNTER(),position,a)
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

    population = ABM{Person}()
    add_agent!(population,person1)
    add_agent!(population,person3)
    add_agent!(population,person2)
    add_agent!(population,person4)
    add_agent!(person5,population)
    add_agent!(person6,population) 

    initDefaultProp!(population,dt=1//12,startTime=1900//1)

    @testset verbose=true "ABM functionalities validation" begin

        @test !verifyAgentsJLContract(population)
        kill_agent!(person2,population)
        @test verifyAgentsJLContract(population)

        @test population.startTime == 1900

        @test population[1] == person1

        @test seed!(population,1) skip=true

        kill_agent!(person2,population)
        @test_throws ArgumentError kill_agent!(person1,population)
        @test nagents(population) == 4

        add_agent!(person1,population) 
        @test nagents(population) == 5

        @test move_agent!(person1,"The Highlands",population) skip=true

    end 

    @testset verbose=true "pre-defined stepping functions of ABMs" begin

        @test dummystep(population) == nothing 
        @test dummystep(person1, population) == nothing 

        @test_throws ErrorException errorstep(population) 

        defaultprestep!(population)
        @test stepnumber(population) == 1 
        
        defaultpoststep!(population) == nothing
        @test currstep(population) > 0

    end 

    age_step!(person::Person,model::ABM{Person}) = 
        person.age += dt(model)
    
    function age_step!(population::ABM{Person})
        agents = allagents(population) 
        for person in agents 
            age_step!(person,population)
        end
        nothing 
    end 

    function population_step!(population::ABM{Person})
        population.currstep += dt(population)
        population.stepnumber += 1
        nothing 
    end
    
    @testset verbose=true "self-defined stepping functions for ABMs" begin 

        initDefaultProp!(population,dt=1//12,startTime=1900//1)

        age_step!(person1,population) 
        @test person1.age > 46 

        age_step!(population)
        @test person6.age == 29.5 

        step!(population,age_step!,12) 
        @test person1.age > 47 && person6.age > 30

        step!(population,age_step!,population_step!,12)
        @test person1.age > 48 && person6.age > 31

        step!(population,defaultprestep!,age_step!,defaultpoststep!,12)
        @test person1.age > 49 && person6.age > 32
        @test population.currstep == 1902 &&  population.stepnumber == 24 
        
    end 
    

end  # testset MultiAgents components 

nothing