"""
    

"""

module Util

    using CSV, Tables     # for reading 2D matrices from a file

    # types 
    export AbstractExample, DummyExample
    
    # global variables 
    export USEAGENTSJL

    # functions 
    export removefirst!, date2yearsmonths

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