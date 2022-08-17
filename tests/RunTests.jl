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

    nothing

end  # testset MultiAgents components 