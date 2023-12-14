Mix.install([{:exla, "~> 0.6.4"}])

Nx.global_default_backend(EXLA.Backend)

defmodule NxBenchmark.Julia do
  import Nx.Defn

  defn julia(matrix, indexes) do
    {dim, _, _} = Nx.shape(matrix)
    matrix = Nx.vectorize(matrix, [:rows, :cols])

    scale = 0.1

    j = scale * (dim - indexes) / dim

    arai = Nx.vectorize(j, [:rows, :cols])

    color = while_julia(arai) * 255

    Nx.concatenate([color, matrix])
    |> Nx.devectorize()
  end

  defn while_julia(arai) do
    case Nx.shape(arai) do
      {2} -> :ok
      _ -> raise "invalid shape"
    end

    ar = arai[0]
    ai = arai[1]

    cr = -0.8
    ci = 0.156

    bool = Nx.as_type(Nx.vectorize(Nx.broadcast(1, Nx.devectorize(ai)), [:rows, :cols]), :u8)

    {_, _, _, _, _, bool} =
      while {ar, ai, n = 200, cr, ci, bool}, n != 0 do
        nar = ar * ar - ai * ai + cr
        nai = ai * ar + ar * ai + ci
        res = nar * nar + nai * nai
        nbool = not (bool == 0) and not (res > 1000)

        {nar, nai, n - 1, cr, ci, nbool}
      end

    bool
  end

  def square_matrix(size) do
    range = 0..(size - 1)

    Enum.map(range, fn index ->
      Enum.map(range, &[index, &1])
    end)
  end
end

[dim] = System.argv()
dim = String.to_integer(dim)

# empty matrix setup
initial_pixel = Nx.tensor([0, 0, 255], type: :f32)
initial_matrix = Nx.broadcast(initial_pixel, {dim, dim, 3}, names: [:x, :y, :pixel])
indexes = Nx.tensor(NxBenchmark.Julia.square_matrix(dim), type: :f32)

# run benchmark
started = System.monotonic_time()
result = NxBenchmark.Julia.julia(initial_matrix, indexes)
finished = System.monotonic_time()
# print result
IO.puts("Nx\t#{dim}\t#{System.convert_time_unit(finished - started, :native, :millisecond)} ")

IO.inspect(result, limit: 1000)
