### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ a84d9990-ccdd-11ed-0a67-33aa723171a0
using Pkg

# ╔═╡ aa9e80a3-e8fb-4324-b654-8d7095268f14
Pkg.activate("/users/asm6/.Julia/dev/IntrinsicDACCycle")

# ╔═╡ 9fa00546-cd3f-46d6-8ea8-08cb071e7971
using Revise

# ╔═╡ b9131b07-61e7-4f4e-9c2d-1cb1b5459770
using IntrinsicDACCycle

# ╔═╡ 32966d7e-6d95-4406-8ae9-fc3229e9e10a
using Metaheuristics

# ╔═╡ ca6a3273-b32d-4373-99c8-1fce640c12f6
using Plots

# ╔═╡ 827927b6-4f3f-484f-aed2-d7746fcfd6ae
Base_directory = "C:/Users/asm6/Documents/Projects/DAC/Results"

# ╔═╡ 572a91bc-5957-48e0-a97a-a2f72b02ce50
begin
	#Define refresh cycle (T, P) path and inlet concentration
	t1 = range(0, 100, 101) #progression of desorption [fake time units]
	t2 = range(0, 100, 101) #progression of desorption [fake time units]
	#Isobarically heat 300 K to 350 K
	T1s = 250.0 .+ (0.5 .* t1) #Temperature [K]  
	P1s = 101325 .+ (0 .* t1) #Pressure [Pa] equal to 1 atmosphere of presure
	#Isothermally pull vaccuum from 1 atm to 0.5 atm.
	T2s = T1s[end] .+ (0.0 .* t2) #Temperature [K] 
	P2s = P1s[end] .+ (-101325/200 .* t2) #Pressure [Pa] equal to 1 atmosphere of presure
	#Concatonate the process steps
	Ts = append!(collect(T1s), collect(T2s))
	Ps = append!(collect(P1s), collect(P2s))
	α = 400/1000000 #400 ppm is the concentration of CO2 in ambient air
end

# ╔═╡ 04ac3d9e-79f7-4c48-b6b1-3bb17931627d
begin
	#specify Start and total Step
	T_start = 273.0 #[K] 
	ΔT = 200.0 #[K]

	T_start_lower = 200.0 #[K]
	T_start_upper = 400.0 #[K]

	ΔT_lower = 0.0 #[K]
	ΔT_upper = 200.0 #[K]

	P_start = 101325.0 #[Pa]
	#limit the ΔP to only reach "rough vaccuum" 100 Pa.
	ΔP = 100.0 - P_start #[Pa] the offset of 1 Pa ensures that the path of P never gets to 0 Pa. 

	P_start_lower = 101325.0 #[Pa] 
	P_start_upper = 1.1 .* [101325.0] #[Pa]

	#Lower limit of ΔP is to reach "rough vaccum" 100 Pa
	ΔP_lower = 100.0 - P_start #[Pa]
	# ΔP_lower = (500 .- P_start[1])./steps .+ zero(ΔP) #[Pa]
	ΔP_upper = 0.0 #[Pa]
	
end


# ╔═╡ 44de46c6-18d6-45b3-8b10-eabf01403fe4
begin
	T_steps = length(T_start:0.5:T_start+ΔT)
	P_steps = length(P_start:-250:P_start+ΔP)

	steps = maximum([T_steps, P_steps])

	test_T = collect(LinRange(T_start, T_start+ΔT, steps))
	test_P = collect(LinRange(P_start, P_start+ΔP, steps))
end

# ╔═╡ 3c685fd5-ab67-49ef-a2f3-c7958edafd88
collect(LinRange(T_start, T_start+ΔT, steps))

# ╔═╡ 351e4648-ef6d-4049-bc1b-6d209651d233
length(T_start:0.5:T_start+ΔT)

# ╔═╡ f28dddcb-2e5e-41d0-a111-c0a47c525475
function ScorePath(parameters)
	T_start = parameters[1]
	ΔT = parameters[2]
	P_start = parameters[3]
	ΔP = parameters[4]
	
	T_steps = length(T_start:0.5:T_start+ΔT)
	P_steps = length(P_start:-250:P_start+ΔP)

	steps = maximum([T_steps, P_steps])

	Ts = collect(LinRange(T_start, T_start+ΔT, steps))
	Ps = collect(LinRange(P_start, P_start+ΔP, steps))

	name = "OKILEA_clean"
	# name = "acs.cgd.5b01554_VAGNUP1452791_clean"
	# name = "CUCKIV_charged"
	ξ, α_end =  IntrinsicDACCycle.Intrinisic_refresh_objectives(Base_directory, 													  name,
															Ts, Ps, α)
	
	objectives = [1/ξ, 1-α_end]
	gx = [0.0] # inequality constraints
    hx = [0.0] # equality constraints
	return objectives, gx, hx
end

# ╔═╡ de0dc6e8-b401-4be4-b25c-f00cdc51952c
begin
	parameters = cat(T_start, ΔT, P_start, ΔP, dims = 1)
	lower_bound = cat(T_start_lower, ΔT_lower, P_start_lower, ΔP_lower, dims = 1)
	upper_bound = cat(T_start_upper, ΔT_upper, P_start_upper, ΔP_upper, dims = 1)
	bounds = cat(lower_bound, upper_bound, dims = 2)'
end

# ╔═╡ 7be547e3-44a3-42cc-a5a3-0bef4f7191f9
ScorePath(parameters)

# ╔═╡ dc058dbe-6f79-48b2-acd3-06967be77656
begin
	N= 400
	method = Metaheuristics.NSGA3(N= N)
	# Metaheuristics.optimize!(ScorePath, bounds, method)
end

# ╔═╡ a23ded95-810a-436e-a0f2-65576f46006c
Metaheuristics.optimize!(ScorePath, bounds, method)

# ╔═╡ eeb4c1ac-bf72-4043-8423-72cdb6e1af86
begin
	results_state = Metaheuristics.get_result(method)
	results = pareto_front(results_state)

	non_dom_solutions = Metaheuristics.get_non_dominated_solutions(method.status.population)
	num_solutions = length(non_dom_solutions)

	results_parameters = Vector{Vector}(undef, num_solutions)

	for (i,solution) in enumerate(non_dom_solutions)
		# @show solution.x
		results_parameters[i] = solution.x
	end
	results_parameters = cat(results_parameters..., dims = 2)'
		
	
end

# ╔═╡ ac9dd29e-9d86-4a32-9bc5-3cb8035e046c
results

# ╔═╡ f1c74094-5d1a-4d28-85ad-8ae9872fdb2d
begin
	cost = results[:,1]	
	@show cost, "J/mol"
	resutlant_ξ = 1 ./ cost
	@show resutlant_ξ, "mol/J"

	inpurity = results[:,2]
	@show inpurity, "mol/mol"
	purity = 1 .-inpurity
	@show purity, "mol/mol"

	path_Ts = Vector{Vector}(undef, length(results_parameters[:,1]))
	path_Ps = Vector{Vector}(undef, length(results_parameters[:,1]))
	for (i,param) in enumerate(eachrow(results_parameters))
	
		path_T_start = param[1]
		path_ΔT = param[2]
		path_P_start = param[3]
		path_ΔP = param[4]
	
		path_T_steps = length(path_T_start:0.5:path_T_start+path_ΔT)
		path_P_steps = length(path_P_start:-250:path_P_start+path_ΔP)
	
		path_steps = maximum([path_T_steps, path_P_steps])
	
		path_Ts[i] = collect(LinRange(path_T_start, path_T_start+path_ΔT, path_steps))
		path_Ps[i] = collect(LinRange(path_P_start, path_P_start+path_ΔP, path_steps))
	end
	
end

# ╔═╡ ba406eb6-58c7-4fb2-a70f-9c74510b0412
begin
plot(path_Ts, path_Ps./P_start)
xlabel!("Temperature (K)")
ylabel!("Pressure (atm)")
end

# ╔═╡ 917c0a33-f8e3-4e9c-9ea9-1158d2d87a5e
results

# ╔═╡ b08f3cbc-daf2-4596-9b3a-1fb0ef63ede1
begin
	pop_f = zeros(length(results_state.population), 2)
	for (i, pop) in enumerate(results_state.population)
		pop_f[i, 1] = pop.f[1]
		pop_f[i, 2] = pop.f[2]
	end
	# A = pareto_front(results)

	
	
	scatter(pop_f[:,1], pop_f[:,2], label="Populuation", markersize = 2)
	scatter!([results[:,1]],[results[:,2]], label="Pareto", 
			 markershape = :star, markersize = 10)
	xlabel!("Cost [J/mol]")
	ylabel!("1-Purity")
end

# ╔═╡ f579ee58-cb55-4422-9d85-3d360736f163
begin
	pareto_ξ = [1 ./ results[:,1]]
	pareto_α = [1 .- results[:,2]]

	pop_ξ = 1 ./ pop_f[:,1]
	pop_α = 1 .- pop_f[:,2]

	scatter(pop_ξ, pop_α, label = "Population", markersize=2,
			# xlim = (0,2.5e-6), ylim=(0.670, 0.675),
			)
	scatter!(pareto_ξ, pareto_α, label = "Pareto", 
			 markershape = :star, markersize = 10)
	xlabel!("Efficiency [mol/J]")
	ylabel!("Purity")
end

# ╔═╡ cfda1228-7087-4e1c-8c2f-95edefcbb980
begin
	scatter(pop_ξ, pop_α, label = "Population", markersize=2,
			xlim = (9.48e-6,9.55e-6), ylim=(.995, 1),
			)
	scatter!(pareto_ξ, pareto_α, label = "Pareto", 
			 markershape = :star, markersize = 10)
	xlabel!("Efficiency [mol/J]")
	ylabel!("Purity")
end

# ╔═╡ b8a112d6-7b4f-4e77-8cf2-9ef2416f8ecc
begin
	all_parameters = zeros(N, length(results_state.best_sol.x))
	for (i, item) in enumerate(method.status.population)
		all_parameters[i,:] = item.x
	end
	all_T_starts = all_parameters[:,1]
	all_ΔTs = all_parameters[:,2]

	all_P_starts = all_parameters[:,3]
	all_ΔPs = all_parameters[:,4]

	all_Ts = Vector{Vector}(undef,N)
	all_Ps = Vector{Vector}(undef,N)

	for i in 1:400
	
		T_start_i = all_parameters[i,1]
		ΔT_i = all_parameters[i,2]

		P_start_i = all_parameters[i,3]
		ΔP_i = all_parameters[i,4]

		T_steps_i = length(T_start_i:0.5:T_start_i+ΔT_i)
		P_steps_i = length(P_start_i:-250:P_start_i+ΔP_i)

		steps_i = maximum([T_steps_i, P_steps_i])

		
		Ts_i = collect(LinRange(T_start_i, T_start_i+ΔT_i, steps_i))
		Ps_i = collect(LinRange(P_start_i, P_start_i+ΔP_i, steps_i))

		all_Ts[i] = Ts_i
		all_Ps[i] = Ps_i
		
	
	end
end

# ╔═╡ bceb620d-fe0c-40f2-972c-a96ee8365f96
begin
	plot(path_Ts, path_Ps,linewidth = 5, linecolor=:red, label="Pareto")
	for i in 1:200
		i_Ts = all_Ts[i]
		i_Ps = all_Ps[i]
		plot!(i_Ts, i_Ps, linecolor=:lightblue, label=false)

	end
	xlabel!("Temperature (K)")
	ylabel!("Pressure (atm)")
end

# ╔═╡ 818dac49-a4f8-483f-b1da-57d9b0a1592a
name = "OKILEA_clean"

# ╔═╡ 96358c21-3559-4782-af16-6695688c4016
begin
	re_eval_1 = IntrinsicDACCycle.Intrinisic_refresh_path(Base_directory, name,
																path_Ts[1], path_Ps[1], 400/1000000)
	
end

# ╔═╡ 20607a25-364d-4c9d-a0b6-cc45d49a2a93
begin
	re_eval_2 = IntrinsicDACCycle.Intrinisic_refresh_path(Base_directory, name,
																path_Ts[2], path_Ps[2], 400/1000000)
	
end

# ╔═╡ 0d70aa0d-9a21-463a-af28-160565e7b2b4
begin
	re_eval = re_eval_1
	for i in 1:2
		re_eval["Refresh_Path"]["Temperatures"] = append!(re_eval_2["Refresh_Path"]["Temperatures"]) 
end

# ╔═╡ 1f8c62db-9689-49e6-a614-3a865643ae04
re_eval_1["E_Balance"]

# ╔═╡ 5e24035e-caab-4aad-a8c2-a705270b359f
begin
	#Start Dictionaries for the results
    Results_Dict = sort(Dict{String, Any}("Name" => name))
    Path_Dict = sort(Dict{String, Any}("Refresh_Path" => "Definition of refresh path and material properties along that path (in per kg of sorbent basis)."))
    E_Balance_Dict = sort(Dict{String, Any}("E_Balance" => "Energy balance along path"))
    Step_1_Dict = sort(Dict{String, Any}("Step_1" => "Adsorption"))
    Step_2_Dict = sort(Dict{String, Any}("Step_2" => "Desorption"))
    Step_3_Dict = sort(Dict{String, Any}("Step_3" => "Waste energy recovery"))

	Path_Dict["Temperatures"] = Vector{Vector}(undef,num_solutions)
    Path_Dict["Temperature_units"] = "K"
    Path_Dict["Pressures"] = Vector{Vector}(undef,num_solutions)
    Path_Dict["Pressure_units"] = "Pa"
    Path_Dict["Betas"] = Vector{Vector}(undef,num_solutions)
    Path_Dict["Beta_units"] = "mol/kJ"

	Path_Dict["Henry_CO2"] = Vector{Vector}(undef,num_solutions)
    Path_Dict["Henry_CO2_err"] = Vector{Vector}(undef,num_solutions)
    Path_Dict["Henry_N2"] = Vector{Vector}(undef,num_solutions)
    Path_Dict["Henry_N2_err"] = Vector{Vector}(undef,num_solutions)
    Path_Dict["Henry_units"] = "mmol/(kg Pa)"
end

# ╔═╡ d24fa094-f8ee-4478-bab4-618b0837f3f7
Path_Dict["Temperatures"][1] = path_Ts[1]

# ╔═╡ ad8cd890-c283-4aa4-9bbf-1508ae4b9b90
Path_Dict["Temperatures"][2] = path_Ts[2]

# ╔═╡ d00819c5-1d46-432a-8a21-89ce7d9f2149
Path_Dict["Betas"][1] = re_eval_1["Refresh_Path"]["Betas"]

# ╔═╡ cdb14900-0505-496b-9eeb-dd1b1009214e


# ╔═╡ 1ec24909-4600-4281-af9c-c011911d5fb9
Path_Dict

# ╔═╡ e3ccdbd6-c14a-4310-af04-dd919d1f00dc
begin
	ting1 = re_eval["Refresh_Path"]["Temperatures"]
	ting2 = re_eval["Refresh_Path"]["Temperatures"]
	ting3 = Vector(ting1)
	ting3 = append!(ting3, Vector(ting2))
end

# ╔═╡ a1283867-39a0-4ab7-8372-d9704b722867
begin
	for i in 1:1
		@show i
	end
end

# ╔═╡ 4f335030-8e38-4e54-9131-8382d5fe5082
crazy_results = IntrinsicDACCycle.Optimize_Intrinsic_Refresh(Base_directory, name, 400/1000000)

# ╔═╡ Cell order:
# ╠═a84d9990-ccdd-11ed-0a67-33aa723171a0
# ╠═aa9e80a3-e8fb-4324-b654-8d7095268f14
# ╠═9fa00546-cd3f-46d6-8ea8-08cb071e7971
# ╠═b9131b07-61e7-4f4e-9c2d-1cb1b5459770
# ╠═827927b6-4f3f-484f-aed2-d7746fcfd6ae
# ╠═32966d7e-6d95-4406-8ae9-fc3229e9e10a
# ╠═ca6a3273-b32d-4373-99c8-1fce640c12f6
# ╠═572a91bc-5957-48e0-a97a-a2f72b02ce50
# ╠═04ac3d9e-79f7-4c48-b6b1-3bb17931627d
# ╠═44de46c6-18d6-45b3-8b10-eabf01403fe4
# ╠═3c685fd5-ab67-49ef-a2f3-c7958edafd88
# ╠═351e4648-ef6d-4049-bc1b-6d209651d233
# ╠═f28dddcb-2e5e-41d0-a111-c0a47c525475
# ╠═de0dc6e8-b401-4be4-b25c-f00cdc51952c
# ╠═7be547e3-44a3-42cc-a5a3-0bef4f7191f9
# ╠═dc058dbe-6f79-48b2-acd3-06967be77656
# ╠═a23ded95-810a-436e-a0f2-65576f46006c
# ╠═eeb4c1ac-bf72-4043-8423-72cdb6e1af86
# ╠═ac9dd29e-9d86-4a32-9bc5-3cb8035e046c
# ╠═f1c74094-5d1a-4d28-85ad-8ae9872fdb2d
# ╠═ba406eb6-58c7-4fb2-a70f-9c74510b0412
# ╠═917c0a33-f8e3-4e9c-9ea9-1158d2d87a5e
# ╠═b08f3cbc-daf2-4596-9b3a-1fb0ef63ede1
# ╠═f579ee58-cb55-4422-9d85-3d360736f163
# ╠═cfda1228-7087-4e1c-8c2f-95edefcbb980
# ╠═b8a112d6-7b4f-4e77-8cf2-9ef2416f8ecc
# ╠═bceb620d-fe0c-40f2-972c-a96ee8365f96
# ╠═818dac49-a4f8-483f-b1da-57d9b0a1592a
# ╠═96358c21-3559-4782-af16-6695688c4016
# ╠═20607a25-364d-4c9d-a0b6-cc45d49a2a93
# ╠═0d70aa0d-9a21-463a-af28-160565e7b2b4
# ╠═1f8c62db-9689-49e6-a614-3a865643ae04
# ╠═5e24035e-caab-4aad-a8c2-a705270b359f
# ╠═d24fa094-f8ee-4478-bab4-618b0837f3f7
# ╠═ad8cd890-c283-4aa4-9bbf-1508ae4b9b90
# ╠═d00819c5-1d46-432a-8a21-89ce7d9f2149
# ╠═cdb14900-0505-496b-9eeb-dd1b1009214e
# ╠═1ec24909-4600-4281-af9c-c011911d5fb9
# ╠═e3ccdbd6-c14a-4310-af04-dd919d1f00dc
# ╠═a1283867-39a0-4ab7-8372-d9704b722867
# ╠═4f335030-8e38-4e54-9131-8382d5fe5082
