
"""Function to read in the GCMC simulation results,
and perform the full intrinsic refresh cycle analysis."""
function Intrinisic_refresh(directory, name)
    #Read in all the GCMC results
    material, Kh_N₂, Kh_CO₂, One_atm_N₂ = read_jsons(directory, name)

    #Test if the Henry constant at 1 atm is close enough to the direct GCMC at 1 atm
    close_enough_test = Close_enough(material, Kh_N₂, One_atm_N₂)
    #If not close enough
    if close_enough_test == false
        return nothing
    end

    #Start Dictionaries for the results
    Results_Dict = sort(Dict{String, Any}("Name" => name))
    Path_Dict = sort(Dict{String, Any}("Refresh_Path" => "Definition of refresh path and material properties along that path (in per kg of sorbent basis)."))
    E_Balance_Dict = sort(Dict{String, Any}("E_Balance" => "Energy balance along path"))
    Step_1_Dict = sort(Dict{String, Any}("Step_1" => "Adsorption"))
    Step_2_Dict = sort(Dict{String, Any}("Step_2" => "Desorption"))
    Step_3_Dict = sort(Dict{String, Any}("Step_3" => "Waste energy recovery"))
    
    #Define refresh cycle (T, P) path and inlet concentration
    t1 = range(0, 100, 101) #progression of desorption [fake time units]
    t2 = range(0, 100, 101) #progression of desorption [fake time units]
	#Isobarically heat 300 K to 350 K
    T1s = 300.0 .+ (0.5 .* t1) #Temperature [K]  
	P1s = 101325 .+ (0 .* t1) #Pressure [Pa] equal to 1 atmosphere of presure
    #Isothermally pull vaccuum from 1 atm to 0.5 atm.
    T2s = T1s[end] .+ (0.0 .* t2) #Temperature [K] 
	P2s = P1s[end] .+ (-101325/200 .* t2) #Pressure [Pa] equal to 1 atmosphere of presure
	#Concatonate the process steps
    Ts = append!(collect(T1s), collect(T2s))
    Ps = append!(collect(P1s), collect(P2s))
    α = 400/1000000 #400 ppm is the concentration of CO2 in ambient air
    βs = T_to_β.(Ts) #[mol/kJ]

    Path_Dict["Temperatures"] = Ts
    Path_Dict["Temperature_units"] = "K"
    Path_Dict["Pressures"] = Ps
    Path_Dict["Pressure_units"] = "Pa"
    Path_Dict["Betas"] = βs
    Path_Dict["Beta_units"] = "mol/kJ"

    #Extrapolate Henry constants along the path
    #Extrapolate the CO2 isotherm to the βs
    Henry_CO2, Henry_CO2_err = Kh_extrapolate(βs, Kh_CO₂, material) #[mmol/(kg Pa)]

    #Extrapolate the N2 isotherm to the βs
    Henry_N2, Henry_N2_err = Kh_extrapolate(βs, Kh_N₂, material)  #[mmol/(kg Pa)]

    Path_Dict["Henry_CO2"] = Henry_CO2
    Path_Dict["Henry_CO2_err"] = Henry_CO2_err
    Path_Dict["Henry_N2"] = Henry_N2
    Path_Dict["Henry_N2_err"] = Henry_N2_err
    Path_Dict["Henry_units"] = "mmol/(kg Pa)"


    #Generate Equilibrium loadings along the path
    n_CO2, n_N2, d_CO2, d_N2, αs = Analytical_Henry_Generate_sorption_path(βs, Ps, α, Henry_CO2, Henry_N2) #[mmol/kg]
    n_CO2 *= 10^-3 #convert to [mol/kg]
    n_N2 *= 10^-3 #convert to [mol/kg]
    d_CO2 *= 10^-3 #convert to [mol/kg]
    d_N2 *= 10^-3 #convert to [mol/kg]

    Path_Dict["Moles_CO2"] = n_CO2
    Path_Dict["Moles_N2"] = n_N2
    Path_Dict["Moles_units"] = "mol/kg"
    
    #Generate heat of adsorption along the path
    q_CO2, q_CO2_err = qₐ∞(βs, Kh_CO₂) #kJ/mol of gas
    q_CO2  *= 10^3 #[J/mol]
    q_CO2_err  *= 10^3 #[J/mol]
    q_N2, q_N2_err = qₐ∞(βs, Kh_N₂) #kJ/mol of gas
    q_N2  *= 10^3 #[J/mol]
    q_N2_err  *= 10^3 #[J/mol]

    Path_Dict["Heat_of_adsorb_CO2"] = q_CO2
    Path_Dict["Heat_of_adsorb_CO2_err"] = q_CO2_err
    Path_Dict["Heat_of_adsorb_N2"] = q_N2
    Path_Dict["Heat_of_adsorb_N2_err"] = q_N2_err
    Path_Dict["Heat_of_adsorb_units"] = "J/mol"
    
    #Generate specific heat of sorbent along the path
    cv_s, cv_s_err =  Extrapolate_Cv(directory, name, Ts) #[J/(kg K)]

    Path_Dict["Specific_heat_sorbent"] = cv_s
    Path_Dict["Specific_heat_sorbent_err"] = cv_s_err
    Path_Dict["Specific_heat_sorbent_units"] = "J/(kg K)"

    #Energy balance for step 1
    (Q_adsorb_CO2, Q_adsorb_N2, 
    W_adsorb_CO2, W_adsorb_N2) = intrinsic_refresh_step_1(Ts, 
                                                    n_CO2, n_N2,
                                                    q_CO2, q_N2)
    # [J/kg_sorb]
    Step_1_Dict["Heat_to_adsorb_CO2"] = Q_adsorb_CO2
    Step_1_Dict["Heat_to_adsorb_N2"] = Q_adsorb_N2
    Step_1_Dict["Work_to_adsorb_CO2"] = W_adsorb_CO2
    Step_1_Dict["Work_to_adsorb_N2"] = W_adsorb_N2
    Step_1_Dict["E_units"] = "J/kg_sorb"

    E1 = Q_adsorb_CO2 +Q_adsorb_N2 + W_adsorb_CO2 + W_adsorb_N2 # [J/kg_sorb]

    E_Balance_Dict["E1"] = E1

    #Energy balance for step 2
    (Q_CO2, Q_N2, 
    W_desorb_CO2, W_desorb_N2, 
    E_heat_ads_CO2, E_heat_ads_N2, 
    E_heat_sorb, E_P) = intrinsic_refresh_step_2(Ts, Ps, 
                                                 n_CO2, n_N2, d_CO2, d_N2,
                                                 q_CO2, q_N2,
                                                 cv_s)
    # [J/kg_sorb]
    Step_2_Dict["Heat_to_desorb_CO2"] = Q_CO2
    Step_2_Dict["Heat_to_desorb_N2"] = Q_N2
    Step_2_Dict["Work_to_desorb_CO2"] = W_desorb_CO2
    Step_2_Dict["Work_to_desorb_N2"] = W_desorb_N2
    Step_2_Dict["E_to_heat_adsorbed_CO2"] = E_heat_ads_CO2
    Step_2_Dict["E_to_heat_adsorbed_N2"] = E_heat_ads_N2
    Step_2_Dict["E_to_heat_sorbent"] = E_heat_sorb
    Step_2_Dict["E_to_change_pressure"] = E_P    
    Step_2_Dict["E_units"] = "J/kg_sorb"
    
    E2 = nansum(Q_CO2 .+ Q_N2 
                .+ W_desorb_CO2 .+ W_desorb_N2 
                .+ E_heat_ads_CO2 .+ E_heat_ads_N2 
                .+ E_heat_sorb .+ E_P)   # [J/kg_sorb]

    E_Balance_Dict["E2"] = E2
    #Energy balance for step 3
    E3 = 0 # [J/kg_sorb]

    Step_3_Dict["E_recovered"] = E3
    E_Balance_Dict["E3"] = E3

    #Total Energy of refresh cycle
    E = E1 + E2 + E3# [J/kg_sorb]

    E_Balance_Dict["Total_E_of_cycle"] = E
    E_Balance_Dict["E_units"] = "J/kg_sorb"

    #Total captureed CO2 and N2
    Δn_CO2 = n_CO2[1] - n_CO2[end] # [mol/kg_sorb]
    Δn_N2 = n_N2[1] - n_N2[end] # [mol/kg_sorb]

    Results_Dict["Captured_CO2"] = Δn_CO2
    Results_Dict["Captured_N2"] = Δn_N2
    Results_Dict["Captured_gas_units"] = "mol/kg_sorb"

    #Calculate performance metrics 
    Intrinsic_capture_efficiency = Δn_CO2/E #[mol/J]
    Purity_captured_CO2 = Δn_CO2/(Δn_CO2 + Δn_N2) #[]

    Results_Dict["Intrinsic_capture_efficiency"] = Intrinsic_capture_efficiency
    Results_Dict["Intrinsic_capture_efficiency_units"] = "mol/J"
    Results_Dict["Purity_captured_CO2"] = Purity_captured_CO2
    #####
    #Write results to JSON
    E_Balance_Dict["Step_1"] = Step_1_Dict
    E_Balance_Dict["Step_2"] = Step_2_Dict
    E_Balance_Dict["Step_3"] = Step_3_Dict

    Results_Dict["Refresh_Path"] = Path_Dict
    Results_Dict["E_Balance"] = E_Balance_Dict

    #Write the results to a JSON file
    results_file = directory*"/Intrinsic_cycle/Intrinsic_cyle_"*name*".json"
    open(results_file, "w") do f
        JSON.print(f, Results_Dict, 4)
    end

    return Results_Dict
end


"""Function to calculate the energy balance during the 
first step of the intrinsic refresh cycle: Adsorption at constat Temperature and total Pressure."""
function intrinsic_refresh_step_1(Ts,
                                  n_CO2, n_N2, 
                                  q_CO2, q_N2)
    Δn_CO2 = n_CO2[1] - n_CO2[end] #[mol/kg_sorb]
    Δn_N2 = n_N2[1] - n_N2[end] #[mol/kg_sorb]

    #Heat of adsorption:
    Q_adsorb_CO2 = Δn_CO2 * q_CO2[1]  #[J/kg_sorb]
    Q_adsorb_N2 = Δn_N2 * q_N2[1] #[J/kg_sorb]
    #Work of gas constracting upon adsorption:
    W_adsorb_CO2 = -(-Δn_CO2) * R * Ts[1] #[J/kg_sorb] reduced from ΔV*P where ΔV = ΔnRT/P
    W_adsorb_N2 = -(-Δn_N2) * R * Ts[1] #[J/kg_sorb] reduced from ΔV*P where ΔV = ΔnRT/P

    return Q_adsorb_CO2, Q_adsorb_N2, W_adsorb_CO2, W_adsorb_N2 #[J/kg_sorb]
end


"""Function to calculate the energy balance during the 
second step of the intrinsic refresh cycle: Desorption along the Temperature and total Pressure path."""
function intrinsic_refresh_step_2(Ts, Ps,
                                  n_CO2, n_N2, d_CO2, d_N2,
                                  q_CO2, q_N2,
                                  cv_s)
    #Ts = Temperatures in [K]
    #Ps = Pressures in [Pa]
    #n_CO2 = absolute adsorbed moles of CO2 per kg of sorbent
    #n_N2 = absolute adsorbed moles of N2 per kg of sorbent
    #d_CO2 = difference in each step of n_CO2 [mol/kg_sorb]
    #d_N2 = difference in each step of n_N2 [mol/kg_sorb]
    #q_CO2 = heat of adsorption of CO2 [J/mol]
    #q_N2 = heat of adsorption of N2 [J/mol]
    #cv_s = Heat capacity at constant volume of sorbent [J/(kg_sorb K)]
    

    #Heat of desorption:
    Q_CO2 = d_CO2 .* q_CO2 #J/kg_sorb
    Q_N2 = d_N2 .* q_N2 #J/kg_sorb

    #Work of expanding gas durring step 2:
    T_midpoints = 0.5 .* (Ts .+ circshift(Ts, 1))[2:end]
    T_midpoints = append!([NaN], T_midpoints)

    W_desorb_CO2 = (d_CO2) .* R .* T_midpoints #J/kg_sorb
    W_desorb_N2 = (d_N2) .* R .* T_midpoints #J/kg_sorb

    #Energy needed to heat adsorbed gas:
    dT = (Ts .- circshift(Ts,1))[2:end] #[K]
	dT = append!([NaN], dT) #[K]

    n_CO2_mid = 0.5 .* (n_CO2 .+ circshift(n_CO2, 1))[2:end] #mol/kg
    n_CO2_mid = append!([NaN],n_CO2_mid)
    
    n_N2_mid = 0.5 .* (n_N2 .+ circshift(n_N2, 1))[2:end] #mol/kg
    n_N2_mid = append!([NaN],n_N2_mid)
    
    E_heat_ads_CO2 = (9/2) .* R .* dT .* n_CO2_mid #J/kg_sorb
    E_heat_ads_N2 = (7/2) .* R .* dT .* n_N2_mid #J/kg_sorb

    #Energy needed to heat sorbent:
    E_heat_sorb = cv_s .* dT #J/kg_sorb

    #Energy needed to change pressure:
    n_gas_mid = n_CO2_mid .+ n_N2_mid #mol/kg_sorb
    log_P = log.(Ps ./ circshift(Ps,1))[2:end] 
    log_P = append!([NaN], log_P)
    E_P = abs.(n_gas_mid .* R .* T_midpoints .* log_P) #J/kg_sorb

    return Q_CO2, Q_N2, W_desorb_CO2, W_desorb_N2, E_heat_ads_CO2, E_heat_ads_N2, E_heat_sorb, E_P
end