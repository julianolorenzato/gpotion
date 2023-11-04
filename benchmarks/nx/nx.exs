Mix.install([
  {:exla, "~> 0.5"},
  # {:nx, "~> 0.6.2"},
], config: [nx: [default_backend: EXLA.Backend]])
