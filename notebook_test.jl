### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ fc3bbee0-7d6b-11ed-2ffe-49240fc0a17a
begin
	import Pkg
    # activate a temporary project environment
	Pkg.activate(mktempdir())
	# Pkg dev the git repo for the local package
	Pkg.develop(; path="C:\\Users\\asm6\\.julia\\dev\\IntrinsicDACCycle\\")

	# install other packages from the standard registry
	Pkg.add([
        Pkg.PackageSpec(; name="GaussianProcesses"),
        Pkg.PackageSpec(; name="JSON"),
		Pkg.PackageSpec(; name="NaNStatistics"),
		Pkg.PackageSpec(; name="LogExpFunctions"),
		Pkg.PackageSpec(; name="Roots"),
		Pkg.PackageSpec(; name="PyCall"),
		Pkg.PackageSpec(; name="Revise"),
		Pkg.PackageSpec(; name="Plots"),
		
	])

    using Revise
    using IntrinsicDACCycle
    using Plots
end

# ╔═╡ 84514e65-6cca-45b8-93b1-f23f8cba120a
begin
	directory = "C:\\Users\\asm6\\Documents\\Projects\\DAC\\Genreate_adsorption_surfaces\\"
	name = "OKILEA"
	output = IntrinsicDACCycle.Intrinsic_refresh(directory, name)
end

# ╔═╡ Cell order:
# ╠═fc3bbee0-7d6b-11ed-2ffe-49240fc0a17a
# ╠═84514e65-6cca-45b8-93b1-f23f8cba120a
