# Kelvin-Helmholtz instability

The files in this folder can be used to reproduce the numerical experiment
simulating a Kelvin-Helmholtz instability with [Trixi.jl](https://github.com/trixi-framework/Trixi.jl).
All results were obtained with Julia v1.6.2 on a computer running Kubuntu 20.04.

To reproduce the numerical experiments and the figure shown in the paper, proceed
as follows.
- Start Julia in this folder and activate the project environment therein
  (e.g., `julia --project=.` in this folder). Pass the command line option
  `--check-bounds=no` to increase the runtime performance. You can also use
  multithreading by passing the command line option `--threads=XXX` to Julia.
- Execute the following code in Julia.
  ```julia
  julia> using Trixi

  julia> trixi_include("elixir_euler_kelvin_helmholtz_instability_amr.jl", tspan=(0.0, 2.0))

  julia> trixi_include("elixir_euler_kelvin_helmholtz_instability_amr.jl", tspan=(0.0, 3.0))
  ```

If you want to modify some plots, you can adapt the plotting commands in
the elixir or work in the Julia REPL as desired.
