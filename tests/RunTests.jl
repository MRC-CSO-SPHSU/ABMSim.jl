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
    end 

    # List of persons 
    person1 = Person(getIDCOUNTER(),"Edinbrugh") 
    person2 = person1               
    person3 = Person(getIDCOUNTER(),"Abderdeen") 
    person4 = Person(getIDCOUNTER(),"Edinbrugh") 
    person5 = Person(getIDCOUNTER(),"Glasgow")
    person6 = Person(getIDCOUNTER(),"Edinbrugh") 

    @testset verbose=true "AbstractAgent verification" begin

        @test verifyAgentsJLContract(person3)
        @test verifyAgentsJLContract(Person)

        println(person1.id) 
        println(person3.id)

    end 

end  # testset MultiAgents components 