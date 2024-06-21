# GraphPPL demo

This code base is using the [Julia Language](https://julialang.org/) and
[DrWatson](https://juliadynamics.github.io/DrWatson.jl/stable/)
to make a reproducible scientific project named
> GraphPPL demo

To (locally) reproduce this project, do the following:

0. Download this code base & download Julia. 
1. Navigate to the project folder in the terminal.
2. Run `julia scripts/run.jl --project=.` in the terminal.

This will install all necessary packages for you to be able to run the scripts and
everything should work out of the box. The plots will be saved in the `plots` folder.

# Reproducing paper visualizations

To reproduce the visualizations from the paper, a script `run.jl` has been included in the `scripts` folder. This script will run all the necessary code to generate the plots. The plots in the paper are generated with TikZ, so the PNG images might look slightly different. However, the TikZ script assumes you have a valid LaTeX installation on your system. If you have LaTeX installed, you can run the code with the `--tikz` flag to generate TikZ code. The command to run then becomes `julia scripts/run.jl --project=. --tikz`.

