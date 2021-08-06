# Adaptive high-order numerical simulations of hyperbolic PDEs with Trixi.jl: A case study of Julia for scientific computing

[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)

This repository contains the source files of the paper on
[Trixi.jl](https://github.com/trixi-framework/Trixi.jl) to be submitted
to the proceedings of JuliaCon 2021. Additionally, it also contains
material to reproduce the numerical experiments reported therein.

## Abstract

We present Trixi.jl, a Julia library for adaptive high-order numerical simulations
of hyperbolic partial differential equations (PDEs). Utilizing Julia's strengths,
Trixi.jl is extendable, easy to use, and fast. We describe the main design choices
that enable these features and compare Trixi.jl with an established open
source Fortran code for hyperbolic PDEs using the same numerical methods.
We conclude with an assessment of Julia for simulation-focused scientific
computing, an area that is still dominated by traditional high-performance
computing languages such as C, C++, and Fortran.


## Reproducing the numerical experiments

- All material necessary to reproduce the simulation of a Kelvin-Helmholtz
  shown in the paper is contained in the folder
  [`figure_kelvin_helmholtz`](figure_kelvin_helmholtz/),
  including a [`README.md`](figure_kelvin_helmholtz/README.md) with instructions.
- All material necessary to reproduce the acoustics simulation on a curved
  high-order mesh shown in the paper is contained in the folder
  [`figure_gingerbread_man`](figure_gingerbread_man/),
  including a [`README.md`](figure_gingerbread_man/README.md) with instructions.
- All material necessary to reproduce the performance comparison with the Fortran
  code [FLUXO](https://github.com/project-fluxo/fluxo) is contained in the folder
  [`pid_runs`](pid_runs/),
  including a [`README.md`](pid_runs/README.md) with instructions.


## Building the paper

The source files of the paper are contained in the folder [`paper`](paper/).
Build the paper by running
```bash
make
```
Clean up your mess afterwards with
```bash
make clean
```


## Useful links

* JuliaCon Proceedings: https://proceedings.juliacon.org/
* Author's guide: https://juliacon.github.io/proceedings-guide/author/


## License

The source code included in this repository is licensed under the MIT license
(see [LICENSE.md](LICENSE.md)). The manuscript is subject to the license of
the JuliaCon proceedings.
