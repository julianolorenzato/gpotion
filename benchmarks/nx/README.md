# How to run NX benchmarks

1. Install [CUDA](https://developer.nvidia.com/cuda-downloads).
2. Install [cuDNN library](https://developer.nvidia.com/cudnn).
3. Set [`XLA_TARGET`](https://github.com/elixir-nx/xla#xla_target) environment variable.
4. Type `elixir benchmarks/nx/[benchmark_name].ex [benchmark_args]`.