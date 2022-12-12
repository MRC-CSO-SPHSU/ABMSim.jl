module Util

    export AbstractExample, DummyExample, DefaultExample 

    export removeFirst!, removeFirstOpt!, date2YearsMonths, getproperty 

    "A super type for all simulation examples"
    abstract type AbstractExample end 

    "Dummy example type"
    struct DummyExample <: AbstractExample end 

    "Default example type"
    struct DefaultExample <: AbstractExample end 

    "remove first occurance of e in list"
    function removeFirst!(list, e)
        e ∉ list ? throw(ArgumentError("element $(e) not in $(list)")) : nothing 
        deleteat!(list, findfirst(x -> x == e, list)) 
        nothing 
    end

    function removeFirstOpt!(list,e) 
        idx = findfirst(x -> x == e, list) 
        len = length(list)
        (list[len], list[idx]) = (list[idx], list[len]) 
        deleteat!(list,len)
        nothing 
    end

    "convert date in rational representation to (years, months) as tuple"
    function date2YearsMonths(date::Rational{Int})
        date < 0 ? throw(ArgumentError("Negative age")) : nothing 
        12 % denominator(date) != 0 ? throw(ArgumentError("$(date) not in age format")) : nothing 
        years  = trunc(Int, numerator(date) / denominator(date)) 
        months = trunc(Int, numerator(date) % denominator(date) * 12 / denominator(date) )
        (years , months)
    end


    "Make dictionaries look like struct for symbols keys"
    Base.getproperty(d::Dict, s::Symbol) = s ∈ fieldnames(Dict) ? getfield(d, s) : getindex(d, s) 


end # module Util 
