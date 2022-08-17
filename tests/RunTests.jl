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
using MultiAgents: add_agent!, kill_agent!
                   

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

    println(typeof(population.properties)) 
    population.properties[:startTime] = 1900 

    @testset verbose=true "ABM functionalities validation" begin

        @test !verifyAgentsJLContract(population)
        kill_agent!(person2,population)
        @test verifyAgentsJLContract(population)

        @test population.startTime == 1900

    end 

end  # testset MultiAgents components 

nothing