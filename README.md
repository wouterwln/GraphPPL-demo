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

To reproduce the visualizations from the paper, a script `run.jl` has been included in the `scripts` folder. This script will run all the necessary code to generate the TikZ code for the visualizations. However, this script assumes you have a valid LaTeX installation on your system. If you don't have LaTeX installed, you can still run the code with the `--png` flag to generate PNG images. These PNG images will not be exactly the same as the ones in the paper (due to the stylization of TikZ), but they will show exactly the same data and results. The command to run then becomes `julia scripts/run.jl --project=. --png`.

