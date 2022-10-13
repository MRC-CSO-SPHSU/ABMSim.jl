using MultiAgents: AbstractXAgent, ABM
using MultiAgents: allagents, nagents 
using MultiAgents: ABMSimulation, AbsFixedStepSim, FixedStepSim, dt, verbose, verboseStep, time 
using MultiAgents: getIDCOUNTER, add_agent!, run!
using MultiAgents: attach_post_model_step!, attach_agent_step!
using MultiAgents.Util: AbstractExample, DefaultExample
import MultiAgents: setup!


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


struct IncomePars
    changeModifier::Float64
end 

mutable struct IncomeVar 
    averageIncome::Float64 
end 

population = ABM{Person}(t = 1980 // 1,
                    parameters = IncomePars(0.1), 
                    variables = IncomeVar(person1.income))    

add_agent!(population,person1)
add_agent!(population,person3)
add_agent!(population,person4)
add_agent!(person5,population)
add_agent!(person6,population) 

println(population)

function incomeChange!(person::Person,pop::ABM{Person},sim=FixedStepSim()) 
    person.income += person.income * ( rand() - 0.5 ) * 2 * pop.parameters.changeModifier
    verboseStep(person.income, "person $(person.id)",sim) 
    nothing 
end

age_step!(person::Person,model::ABM{Person},sim::AbsFixedStepSim) = 
    person.age += dt(sim)

function incomeAvg!(pop::ABM{Person},sim::ABMSimulation) 
    ret = 0
    for person in allagents(pop)
        ret += person.income 
    end
    pop.variables.averageIncome = ret / nagents(pop)
    verboseStep(pop.variables.averageIncome,"average income",sim)  
    nothing 
end 


function setup!(abmsim::ABMSimulation,::DefaultExample) 
    attach_agent_step!(abmsim,age_step!)
    attach_agent_step!(abmsim,incomeChange!)
    attach_post_model_step!(abmsim,incomeAvg!)
    nothing         
end 

abmsim = ABMSimulation( dt=1//12,
                    startTime= time(population), finishTime=1990,
                    verbose=true, yearly=true) 

println(abmsim)

println(population)

run!(population,abmsim)

println(population)

println(abmsim.stepnumber)