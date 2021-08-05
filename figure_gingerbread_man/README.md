# Acoustic wave scattering on a gingerbread man

The files in this folder can be used to reproduce the numerical experiment
simulating Acoustic wave scattering on a gingerbread man mesh
with [Trixi.jl](https://github.com/trixi-framework/Trixi.jl).
The provided control file `mesh_gingerbread_man.control` is used by
[HOHQMesh.jl](https://github.com/trixi-framework/HOHQMesh.jl) to generate the
unstrucutred quad mesh file for this simulation. Once generated, the mesh file
`mesh_gingerbread_man.mesh` is placed in the `out` folder.
All results were obtained with Julia v1.6.2 on a computer running macOS Big Sur 11.5.

To reproduce the numerical experiments and the figure shown in the paper, proceed
as follows.
- Start Julia in this folder and activate the project environment therein
  (e.g., `julia --project=.` in this folder). Pass the command line option
  `--check-bounds=no` to increase the runtime performance. You can also use
  multithreading by passing the command line option `--threads=XXX` to Julia.
- Execute the following code in Julia.
  ```julia
  julia> using Trixi

  julia> trixi_include("elixir_ape_gingerbread_man.jl", tspan=(0.0, 8.0))

  julia> trixi_include("elixir_ape_gingerbread_man.jl", tspan=(0.0, 16.0))
  ```

This will produce the necessary `.vtu` plot files that can be opened with ParaView to
visualize the solution.
