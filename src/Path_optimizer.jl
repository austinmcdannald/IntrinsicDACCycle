
"""Function to find the set of pareto optimal paths
for the intrinsic refresh cycle of each material.
"""
function find_pareto_path(directory::String, name::String, α)
    #Specify the prior distributions of the path
    steps = 202
    T_start = Uniform(250, 350) #[K] Start anywhere between 250 K and 350 K. 
    dT_s = Uniform(0,2, steps) #[K] Each of the steps can be between 0 K and 2 K.
    P_start = Uniform(101325 *0.9, 101325 *1.1) #[Pa] Start anywhere between +/- 10% of 1 atm
    dP_s = Uniform(0, -2000, steps) #[Pa] Each of the steps can be between 0 Pa and -2000 Pa.

    #Make the path and return the objective funcitons
    function path_evaluate(T_start, dT_s, P_start, dP_s)
        #Make the path
        Ts = T_start .+ cumsum(dT_s)
        Ps = P_start .+ cumsum(dP_s)

        #Perform the Intrinsic_refresh along that path
        Results = Intrinisic_refresh_path(directory, name,
                                          Ts, Ps, α)
        #Objective to maximize:
        objective1 = Results["Purity_captured_CO2"]
        #Objective to maximize:
        objective2 = Results["Intrinsic_capture_efficiency"]

        return objective1, objective2, Results
    end

    #Find the pareto optimal path
    pareto_paths = ParetoOptimize((T_start, dT_s, P_start, dP_s) -> path_evaluate(T_start, dT_s, P_start, dP_s), (1,2))

    #Save the results on the set pareto paths
      



end