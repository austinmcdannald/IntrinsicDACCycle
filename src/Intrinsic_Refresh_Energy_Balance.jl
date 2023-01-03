
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
    
    #Define refresh cycle (T, P) path and inlet concentration
    t = range(0, 100, 101) #progression of desorption [fake time units]
	Ts = 350.0 .+ (1 .* t) #Temperature [K] 
	Ps = 101325 .+ (0 .* t) #Pressure [Pa] equal to 1 atmosphere of presure
    α = 400/1000000 #400 ppm is the concentration of CO2 in ambient air
    βs = T_to_β.(Ts) #[mol/kJ]

    #Generate Equilibrium loadings along the path
    n_CO2, n_N2, d_CO2, d_N2, αs = Analytical_Henry_Generate_sorption_path(Ts, Ps, α, Kh_CO₂, Kh_N₂, material) #[mmol/kg]
    n_CO2 *= 10^-3 #convert to [mol/kg]
    n_N2 *= 10^-3 #convert to [mol/kg]
    d_CO2 *= 10^-3 #convert to [mol/kg]
    d_N2 *= 10^-3 #convert to [mol/kg]


    #Generate heat of adsorption along the path
    q_CO2, q_CO2_err = qₐ∞(βs, Kh_CO₂) #kJ/mol of gas
    q_CO2  *= 10^3 #[J/mol]
    q_CO2_err  *= 10^3 #[J/mol]
    q_N2, q_N2_err = qₐ∞(βs, Kh_N₂) #kJ/mol of gas
    q_N2  *= 10^3 #[J/mol]
    q_N2_err  *= 10^3 #[J/mol]

    #Generate specific heat of sorbent along the path
    cv_s, cv_s_errs =  Extrapolate_Cv(directory, name, Ts) #[J/(kg K)]
    cv_s *= 10^-3 #convert to [kJ/(kg K)]
    cv_s_errs *= 10^-3 #convert to [kJ/(kg K)]

    #Energy balance for step 1
    (Q_adsorb, W_adsorb) = intrinsic_refresh_step_1(Ts, 
                                                    n_CO2, n_N2,
                                                    q_CO2, q_N2)
    @show Q_adsorb
    @show W_adsorb
    E1 = Q_adsorb + W_adsorb

    #Energy balance for step 2
    (Q_CO2, Q_N2, 
    W_desorb_CO2, W_desorb_N2, 
    E_heat_ads_CO2, E_heat_ads_N2, 
    E_heat_sorb, E_P) = intrinsic_refresh_step_2(Ts, Ps, 
                                                 n_CO2, n_N2, d_CO2, d_N2,
                                                 q_CO2, q_N2,
                                                 cv_s)
    E2 = nansum(Q_CO2 .+ Q_N2 
                .+ W_desorb_CO2 .+ W_desorb_N2 
                .+ E_heat_ads_CO2 .+ E_heat_ads_N2 
                .+ E_heat_sorb .+ E_P)   
    #Energy balance for step 3
    E3 = 0

    #Total Energy of refresh cycle
    E = E1 + E2 + E3

    #Total captureed CO2 and N2
    Δn_CO2 = n_CO2[1] - n_CO2[end]
    Δn_N2 = n_N2[1] - n_N2[end]

    #Calculate performance metrics 
    Intrinsic_capture_efficiency = Δn_CO2/E
    Purity_captured_CO2 = Δn_CO2/(Δn_CO2 + Δn_N2)

    #####
    #Write results to JSON

    return Intrinsic_capture_efficiency, Purity_captured_CO2
end


"""Function to calculate the energy balance during the 
first step of the intrinsic refresh cycle: Adsorption at constat Temperature and total Pressure."""
function intrinsic_refresh_step_1(Ts,
                                  n_CO2, n_N2, 
                                  q_CO2, q_N2)
    Δn_CO2 = n_CO2[1] - n_CO2[end] #[mol/kg_sorb]
    Δn_N2 = n_N2[1] - n_N2[end] #[mol/kg_sorb]
    #Heat of adsorption:
    Q_adsorb = Δn_CO2 * q_CO2[1] + Δn_CO2 * q_N2[1] #[J/kg_sorb]

    #Work of gas constracting upon adsorption:
    W_adsorb = (-Δn_CO2 - Δn_N2) * R * Ts[1] #[J/kg_sorb] reduced from ΔV*P where ΔV = ΔnRT/P
    

    return Q_adsorb, W_adsorb 
end


"""Function to calculate the energy balance during the 
second step of the intrinsic refresh cycle: Desorption along the Temperature and total Pressure path."""
function intrinsic_refresh_step_2(Ts, Ps,
                                  n_CO2, n_N2, d_CO2, d_N2,
                                  q_CO2, q_N2,
                                  cv_s)
    #Heat of desorption:
    Q_CO2 = d_CO2 .* q_CO2 .* 1e3 #J/kg_sorb
    Q_N2 = d_N2 .* q_N2 .* 1e3 #J/kg_sorb

    #Work of expanding gas durring step 2:
    T_midpoints = 0.5 .* (Ts .+ circshift(Ts, 1))[2:end]
    T_midpoints = append!([NaN], T_midpoints)

    W_desorb_CO2 = (d_CO2) .* R .* T_midpoints #J/mol_sorb
    W_desorb_N2 = (d_N2) .* R .* T_midpoints #J/mol_sorb

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
    E_P = n_gas_mid .* R .* T_midpoints .* log_P #J/kg_sorb

    return Q_CO2, Q_N2, W_desorb_CO2, W_desorb_N2, E_heat_ads_CO2, E_heat_ads_N2, E_heat_sorb, E_P
end