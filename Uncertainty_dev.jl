### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ fea28170-74cb-11ee-052f-cd5041d01722
using Pkg

# ╔═╡ d4376d43-56c8-46f5-91ba-14d9a2e6bcb9
Pkg.activate("C:/Users/asm6/.julia/dev/IntrinsicDACCycle")
# Pkg.instantiate("C:/Users/asm6/.julia/dev/IntrinsicDACCycle")

# ╔═╡ 96b977eb-09e4-47d0-a44f-e84754e44bcf
Pkg.add("UMAP")

# ╔═╡ 39adca47-0916-40bf-9a68-ccca916286bc
using Revise

# ╔═╡ 800ca690-0b6f-488d-80aa-34bb8c9d28e4
using IntrinsicDACCycle

# ╔═╡ 79e0e799-7652-4647-b3e6-e38b50936eee
using Metaheuristics

# ╔═╡ 0562ebed-0c40-48ef-87a7-9aaf9d129141
using Statistics

# ╔═╡ 1190b5f5-1ae9-49d0-a6e1-631f315a779f
using Plots

# ╔═╡ 9679c9dc-b2cb-4542-a11c-ba152d252fcd
using UMAP

# ╔═╡ 9b4bdf3e-f56a-46f4-9b12-181791871870
#Pkg.activate("/users/asm6/.Julia/dev/IntrinsicDACCycle")

# ╔═╡ 9014e932-b0ff-4d0c-8cfe-14a83c0df77d


# ╔═╡ 35ce9d94-7205-4322-b6f2-0016e74895c5
Base_directory = "C:/Users/asm6/Documents/Projects/DAC/Results"

# ╔═╡ 38d44cae-df73-4dd1-bdc2-f4498fffd17f
begin
	# name = "OKILEA_clean"
	name = "acs.cgd.5b01554_VAGNUP1452791_clean"
	# name = "CUCKIV_charged"
end

# ╔═╡ 92ee65e1-e046-42da-bf20-ab4dd0abbbcf
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

# ╔═╡ f2fa8a18-60c0-4d3c-8e80-8ea5dd0de69a
Objecive_dist = 	 
    IntrinsicDACCycle.Intrinisic_refresh_objectives_posterior_dist(
		Base_directory, name,
		Ts, Ps, α,
		500
	)

# ╔═╡ 1d4927ee-5bef-4ee8-86b6-654efef4abb9
[mean(Objecive_dist[1]), std(Objecive_dist[1])]

# ╔═╡ b3fb388d-3b00-42e9-adc2-f48f4ff055d6
[mean(Objecive_dist[2]), std(Objecive_dist[2])]

# ╔═╡ 39ada708-596a-4685-831a-f755f5227f3d
histogram(Objecive_dist[1])

# ╔═╡ 03c44985-94a6-47d9-96a5-0de6f7abcbdf
histogram(Objecive_dist[2])

# ╔═╡ bdd44a58-e966-4edd-8a79-4844f83ad442
histogram(Objecive_dist[3])

# ╔═╡ 34ddcf3d-5f69-4fd1-93db-882c5c209c30
histogram(Objecive_dist[4])

# ╔═╡ 0ede4183-46d2-47ea-9a66-29191cea7549
Results_dict = IntrinsicDACCycle.Optimize_Intrinsic_Refresh(Base_directory, name, α)

# ╔═╡ aa5da8a4-ee18-435c-a5b4-57c278907511
Results_dict_2 = IntrinsicDACCycle.Optimize_Intrinsic_Refresh_w_err(Base_directory, name, α)

# ╔═╡ 99ebe87f-cf56-4647-b489-f9f2416adc23
plot(Results_dict["Refresh_Path"]["Temperatures"], Results_dict["Refresh_Path"]["Pressures"])

# ╔═╡ 980e56de-6d31-4fa7-856a-71e85f52a3d9
plot(Results_dict_2["Refresh_Path"]["Temperatures"], Results_dict_2["Refresh_Path"]["Pressures"])

# ╔═╡ 92513c81-1076-4443-a651-858cde1485a5
begin
	dT_max = 0.25
	for i in 0:20
		T1 = 200.0
		ΔT = 200.0
		dT_max_i = dT_max*0.75^i   
		thing = T1:dT_max_i:T1+ΔT
		@show length(thing)
	end
end

# ╔═╡ b515a8f1-af51-4414-8b4f-41641b0aa8d2


# ╔═╡ Cell order:
# ╠═fea28170-74cb-11ee-052f-cd5041d01722
# ╠═9b4bdf3e-f56a-46f4-9b12-181791871870
# ╠═d4376d43-56c8-46f5-91ba-14d9a2e6bcb9
# ╠═9014e932-b0ff-4d0c-8cfe-14a83c0df77d
# ╠═39adca47-0916-40bf-9a68-ccca916286bc
# ╠═800ca690-0b6f-488d-80aa-34bb8c9d28e4
# ╠═79e0e799-7652-4647-b3e6-e38b50936eee
# ╠═0562ebed-0c40-48ef-87a7-9aaf9d129141
# ╠═1190b5f5-1ae9-49d0-a6e1-631f315a779f
# ╠═96b977eb-09e4-47d0-a44f-e84754e44bcf
# ╠═9679c9dc-b2cb-4542-a11c-ba152d252fcd
# ╠═35ce9d94-7205-4322-b6f2-0016e74895c5
# ╠═38d44cae-df73-4dd1-bdc2-f4498fffd17f
# ╠═92ee65e1-e046-42da-bf20-ab4dd0abbbcf
# ╠═f2fa8a18-60c0-4d3c-8e80-8ea5dd0de69a
# ╠═1d4927ee-5bef-4ee8-86b6-654efef4abb9
# ╠═b3fb388d-3b00-42e9-adc2-f48f4ff055d6
# ╠═39ada708-596a-4685-831a-f755f5227f3d
# ╠═03c44985-94a6-47d9-96a5-0de6f7abcbdf
# ╠═bdd44a58-e966-4edd-8a79-4844f83ad442
# ╠═34ddcf3d-5f69-4fd1-93db-882c5c209c30
# ╠═0ede4183-46d2-47ea-9a66-29191cea7549
# ╠═aa5da8a4-ee18-435c-a5b4-57c278907511
# ╠═99ebe87f-cf56-4647-b489-f9f2416adc23
# ╠═980e56de-6d31-4fa7-856a-71e85f52a3d9
# ╠═92513c81-1076-4443-a651-858cde1485a5
# ╠═b515a8f1-af51-4414-8b4f-41641b0aa8d2
