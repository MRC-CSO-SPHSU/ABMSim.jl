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
using MultiAgents: getIDCOUNTER

@testset "MultiAgents Components Testing" begin
    
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


end  # testset MultiAgents components 