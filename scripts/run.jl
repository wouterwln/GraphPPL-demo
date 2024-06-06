using Pkg
Pkg.Registry.update()
Pkg.activate(".")
Pkg.resolve()
Pkg.instantiate()
Pkg.precompile()

using DrWatson
@quickactivate "GraphPPL demo"

# Here you may include files from the source directory
include(srcdir("experiments.jl"))

println(
    """
    Experiments run successfully!
    Plots are in the `plots`` directory.
    """
)
