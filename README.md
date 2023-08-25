# ABMSim.jl

[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

### Title 

ABMSim.jl: An agent-based model simultor 

### Descritpion 

This package provides simple ABM model and simulation types, currently tuned for large-scale demographic ABMs, cf.\ [LPM.jl package](https://github.com/MRC-CSO-SPHSU/LPM.jl). It strives to make use of the state-of-the-art Agents.jl package. 

### Author(s) 
[Atiyah Elsheikh](https://www.gla.ac.uk/schools/healthwellbeing/staff/atiyahelsheikh/)

### Contributor(s)  
Atiyah Elsheikh (V0-V0.6)  

### Releases

- **V0.1** (28-06-2022) : Basic abstract functionalities of Multiagents models (Agents, ABMs, MultiABMs, ABM Simulation, MABM Simulations)
- **V0.2** (25-08-2022) : ABM-type has parameter fields + Unit Testing (Agents & ABMs)

   - V0.2.1   (29-08-2022) : Minor simplifcation when using MABMSimulation
   - V0.2.2   (09-09-2022) : ABM.propoerties look like structure if declared as dictionaries, initializing MA for reseting ID coutner, version number const
   - V0.2.3   (22-09-2022) : ABM.data does not need to of dictionary type. 
   - V0.2.4   (1-10-2022)  : Remove the usage of SomeUtil.jl and replace it with internal utilities module
  
- **V0.3** (21-10-2022) :  removing all static dictionaries declaration, removing major causes of type instabilities, simulation parameters type for fixed step simulation (subject to improvement), allowing several type of simulations  (agents.jl-like, simple fixed step, simple ABM) with DRY-based style, no MABM or MABM simulation concrete types (not needed by current case study), comprehensive set of unit tests across the whole package (90 unit tests), time is not associated with the model but implicitly embedded in a simulation type, stepping and running a model can use example as a trait (with DefaultExample() if not specified) 

   - V0.3.1   (7-11-2022)  : User-arbitrary types for simulation parameters 
   
 - **V0.4**   (14-12-2022) : optimized implementation of kill_agent!, simple and parameterized ABM type, blueStyle coding guidelines, constistent naming conventions of source files, unit tests increased to 101
 - **V0.5**   (5-3-2023)   : Importing common functions from Agents.jl + bluestyle coding recommended editor settings 

   - V0.5.1   (19-5)       : Minor issues , missing export statmenet
      
 - **V0.6**   (25-8)       : Renaming to ABMSim.jl

### License
MIT License

Copyright (c) 2023 Atiyah Elsheikh, MRC/CSO Social & Public Health Sciences Unit, School of Health and Wellbeing, University of Glasgow, Cf. [License](https://github.com/MRC-CSO-SPHSU/MiniDemographicABM.jl/blob/master/LICENSE) for further information

### Platform 
This code was developed and experimented on 
- Ubuntu 22.04.2 LTS
- VSCode V1.71.2
- Julia language V1.9.1
- Agents.jl V5.14.0

### Exeution 

This is a library with no internal examples. However, cf. [LPM.jl package](https://github.com/MRC-CSO-SPHSU/LPM.jl) as an example. 

Execution of unit tests within REPL: 

<code>  
  > push!(LOAD_PATH,"/home/atiyah/work/julia/ABMSim.jl/")
  > include("tests/runtests")
</code> 

