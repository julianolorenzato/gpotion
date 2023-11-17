Mix.install([{:exla, "~> 0.6.4"}])

Nx.global_default_backend(EXLA.Backend)

defmodule NxBenchmark.NBodies do
  
end
