"""
    

"""

module Util

    using CSV, Tables     # for reading 2D matrices from a file

    # types 
    export AbstractExample, DummyExample
    
    # global variables 
    export USEAGENTSJL

    # functions 
    export removefirst!, date2yearsmonths, subtract!


    """
    A super type for example 

    The purpose is to provide type traits for overloading 
    functions that need to be overloaded, e.g. setup!(::AbstractSimulation,::ExampleType) 

    Main usage 

    struct ExampleName <: AbstractExample end

    import Simulations: setup!

    function setup!(sim::SimulationType;example::ExampleName) 
        # implementation, e.g. setup stepping functions 
    end 
    """

    "A super type for all simulation examples"
    abstract type AbstractExample end 

    "Default dummy example type"
    struct DummyExample <: AbstractExample end 

    # list of global variables

    "whether the package Agents.jl shall be used" 
    const USEAGENTSJL = false      # Still not employed / implemented 

    "remove first occurance of e in list"
    function removefirst!(list, e)
        e ∉ list ? throw(ArgumentError("element $(e) not in $(list)")) : nothing 
        deleteat!(list, findfirst(x -> x == e, list)) 
        nothing 
    end

    """
    Subtract keys from a given dictionary
    @argument dict : input dictionary 
    @argument ks   : input keys
    @throws  ArgumentError if a key in keys not available in dict  
    @return a new dictionary with exactly the specified keys 
    """ 
    function  subtract!(ks::Vector{Symbol},dict::Dict) 
        if  ks ⊈  keys(dict) 
            throw(ArgumentError("$ks ⊈  $(keys(dict))")) 
        end 
        newdict = Dict{Symbol,Any}()  
        for key ∈ ks 
            newdict[key] = dict[key] 
            delete!(dict,key) 
        end 
        newdict 
    end 

    "" 
    Base.:(-)(ks::Vector{Symbol},dict::Dict) = subtract!(ks,dict) 

    "Read and return a 2D array from a file without a header"
    function read2DArray(fname::String)
        CSV.File(fname,header=0) |> Tables.matrix
    end 

    "convert date in rational representation to (years, months) as tuple"
    function date2yearsmonths(date::Rational)
        date < 0 ? throw(ArgumentError("Negative age")) : nothing 
        12 % denominator(date) != 0 ? throw(ArgumentError("$(date) not in age format")) : nothing 
        years  = trunc(Int, numerator(date) / denominator(date)) 
        months = trunc(Int, numerator(date) % denominator(date) * 12 / denominator(date) )
        (years , months)
    end

end # Util 