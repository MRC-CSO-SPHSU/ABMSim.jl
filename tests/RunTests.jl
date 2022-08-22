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
using MultiAgents: add_agent!, kill_agent!, seed!, nagents
using MultiAgents: errorstep, dummystep
using MultiAgents: initDefaultProp!, defaultprestep!, defaultpoststep!,
                    currstep, stepnumber, dt
                   

@testset "MultiAgents Components Testing" begin
    
    initMultiAgents()

    mutable struct Person <: AbstractXAgent 
        id::Int 
        pos 

        Person(position) = new(getIDCOUNTER(),position)
    end 

    # List of persons 
    person1 = Person("Edinbrugh") 
    person2 = person1               
    person3 = Person("Abderdeen") 
    person4 = Person("Edinbrugh") 
    person5 = Person("Glasgow")
    person6 = Person("Edinbrugh") 

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

    initDefaultProp!(population,dt=1,startTime=1900)

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

end  # testset MultiAgents components 

nothing