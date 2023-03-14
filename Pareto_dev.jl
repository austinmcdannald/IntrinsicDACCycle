### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 506d1910-c276-11ed-0daa-2967048541da
using Pkg

# ╔═╡ d9a7da1b-ad1b-40c4-809f-0434d22dfa71
Pkg.activate("/users/asm6/.Julia/dev/IntrinsicDACCycle")

# ╔═╡ 765111ae-5b7a-447c-9f0d-be12b7ce738e
Pkg.add("Evolutionary")

# ╔═╡ a2978e82-d421-43a2-a1a1-30aaa7afb7e4
using Revise

# ╔═╡ 6b01655d-022d-451e-98c7-568cc3f61e54
using IntrinsicDACCycle

# ╔═╡ 7fa47b3d-c53c-477c-b1ed-ff1c7ad2e0f0
using Evolutionary 

# ╔═╡ 25cae43e-33a0-4d7d-bda9-be48d9344b63
Base_directory = "C:/Users/asm6/Documents/Projects/DAC/Results"

# ╔═╡ 2d9d00f3-3e61-45e4-a7f6-dd7108034e1e
thing = IntrinsicDACCycle.Intrinisic_refresh(Base_directory, "OKILEA_clean")

# ╔═╡ 7fe6bbb2-f225-4811-88c5-9b6c3de48981


# ╔═╡ Cell order:
# ╠═506d1910-c276-11ed-0daa-2967048541da
# ╠═d9a7da1b-ad1b-40c4-809f-0434d22dfa71
# ╠═a2978e82-d421-43a2-a1a1-30aaa7afb7e4
# ╠═6b01655d-022d-451e-98c7-568cc3f61e54
# ╠═25cae43e-33a0-4d7d-bda9-be48d9344b63
# ╠═765111ae-5b7a-447c-9f0d-be12b7ce738e
# ╠═7fa47b3d-c53c-477c-b1ed-ff1c7ad2e0f0
# ╠═2d9d00f3-3e61-45e4-a7f6-dd7108034e1e
# ╠═7fe6bbb2-f225-4811-88c5-9b6c3de48981
