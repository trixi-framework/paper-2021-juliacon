# Performance index (PID) computations of Trixi and FLUXO

The files in this folder can be used to reproduce the numerical experiments
for the performance comparison between the fortran code
[FLUXO](https://github.com/project-fluxo/fluxo) and the Julia code
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl).
All results reported in the paper were obtained with the Intel compiler suite v18.0.03
and Julia v1.6.1. The runs were performed with a single Intel Xeon Gold 6130 processor
on [Tetralith](https://www.nsc.liu.se/systems/tetralith/) an HPC cluster maintained by the
[Swedish National Infrastrucutre for Computing (SNIC)](https://snic.se/).

## Trixi.jl run instructions

To reproduce the Trixi.jl numerical PID experiments, proceed as follows.
- Start Julia in this folder and activate the project environment therein
  ```shell
  > julia --project=@. --threads=1 --check-bounds=no
  ```
- Execute one of the included elixir files, either `elixir_euler_pid.jl` for the
  3D compressible Euler equations on a heavily warped periodic box mesh or `elixir_mhd_pid.jl`
  for the 3D ideal GLM-MHD equations on a heavily warped periodic box mesh. One can vary the polynomial
  degree (`polydeg`) directly from the REPL. For example, one can run a compressible Euler test with fifth
  order polynomials using the commands
  ```julia
  julia> using Trixi

  julia> trixi_include("elixir_euler_pid.jl", polydeg=5)
  ```
- The PID is a quantity reported during the Trixi.jl simulation and is easily extracted.
  Below is an example check-in terminal output from the simulation setup run with
  the commands in the previous step:
  ```
  ────────────────────────────────────────────────────────────────────────────────────────────────────
   Simulation running 'CompressibleEulerEquations3D' with DGSEM(polydeg=5)
  ────────────────────────────────────────────────────────────────────────────────────────────────────
   #timesteps:                200                run time:       3.93717669e+00 s
   Δt:             4.94155838e-03                time/DOF/rhs!:  5.86020104e-08 s
   sim. time:      9.53523721e-01
   #DOF:                    13824
   #elements:                  64

   Variable:       rho              rho_v1           rho_v2           rho_v3           rho_e
   L2 error:       3.89745194e-03   3.08224319e-03   3.73575208e-03   3.82055431e-03   5.96909051e-03
   Linf error:     9.32386945e-02   6.21319993e-02   9.94372780e-02   9.33482995e-02   1.49278473e-01
   ∑∂S/∂U ⋅ Uₜ :   9.90536480e-06
  ────────────────────────────────────────────────────────────────────────────────────────────────────
  ```
  The PID information is found on the top right where `time/DOF/rhs!:  5.86020104e-08 s`.
- In order to change the type of DG solver used during the comparsion one must make some simple edits
  to either of the included elixir files. As commited in this repo, the weak form DG solver with the
  HLL surface flux is used by default. To change to the flux differencing entropy conservative DG
  solver comment the weak form solver instructions and uncomment the flux differencing commands, e.g.,
  in `elixir_euler_pid.jl` edit lines 17-24 to become
  ```julia
  # For ECKEP flux split form
  volume_flux = flux_ranocha
  solver = DGSEM(polydeg=3, surface_flux=flux_ranocha,
                 volume_integral=VolumeIntegralFluxDifferencing(volume_flux))

  # For standard DG weak form + HLL
  #solver = DGSEM(polydeg=3, surface_flux=flux_hll,
  #               volume_integral=VolumeIntegralWeakForm())
  ```

## FLUXO compilation and run instructions



FLUXO version of the `master` branch on August 6, 2021 with commit hash `f16435a779ca342b44b12d0475506ec2d25e7db9`.

Mesh made with HOPR

