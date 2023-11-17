Mix.install([{:exla, "~> 0.6.4"}])

Nx.global_default_backend(EXLA.Backend)

defmodule NxBenchmark.Julia do
  import Nx.Defn

  defn julia(matrix) do
    {dim, _, _} = Nx.shape(matrix)

    scale = 0.1

    indexes_x = Nx.iota({dim, dim}, axis: 1, type: :f32, names: [:x, :y])
    jx = scale * (dim - indexes_x) / dim

    indexes_y = Nx.iota({dim, dim}, axis: 1, type: :f32, names: [:y, :x])
    jy = scale * (dim - indexes_y) / dim

    cr = -0.8
    ci = 0.156
    ar = jx
    ai = jy

    n = 200
    number = 2000

    nar = (ar * ar - ai * ai) + cr
    nai = (ai * ar - ar * ai) + ci
  end
end

[dim] = System.argv()
dim = String.to_integer(dim)

# empty matrix setup
initial_pixel = Nx.tensor([0, 0, 0, 255], type: :f32)
initial_matrix = Nx.broadcast(initial_pixel, {dim, dim, 4}, names: [:x, :y, :pixel])

# run benchmark
started = System.monotonic_time()
result = NxBenchmark.Julia.julia(initial_matrix)
finished = System.monotonic_time()

# print result
IO.puts(
  "Nx\t#{matrix_size}\t#{System.convert_time_unit(finished - started, :native, :millisecond)} "
)

IO.inspect(result)
