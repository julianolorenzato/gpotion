Mix.install([{:exla, "~> 0.6.4"}])

# Nx.global_default_backend(EXLA.Backend)

defmodule NxBenchmark.Julia do
  import Nx.Defn

  defn julia(matrix, indexes) do
    {dim, _, _} = Nx.shape(matrix)

    scale = 0.1

    # indexes_x = Nx.iota({dim, dim}, axis: 0, type: :f32, names: [:x, :y])
    # indexes_y = Nx.iota({dim, dim}, axis: 1, type: :f32, names: [:x, :y])

    # jx = scale * (dim - indexes_x) / dim
    # jy = scale * (dim - indexes_y) / dim

    j = scale * (dim - indexes) / dim

    # cr = -0.8
    # ci = 0.156
    # ar = jx
    # ai = jy

    # n = 200

    # nar = (ar * ar - ai * ai) + cr
    # nai = (ai * ar - ar * ai) + ci

    while_julia(Nx.vectorize(j, [:rows, :cols]))
  end

  defn while_julia(arai) do
    case Nx.shape(arai) do
      {2} -> :ok
      _ -> raise "invalid shape"
    end

    # case Nx.type(arai) do
    #   {:f, 32} -> :ok
    #   _ -> raise "invalid type"
    # end

    ar = arai[0]
    ai = arai[1]

    cr = -0.8
    ci = 0.156

    {_, _, n, _, _} =
      while {ar, ai, n = Nx.tensor(200, type: :f32), cr, ci},
            n != 0 or ar * ar + ai * ai > 1000 do
        nar = ar * ar - ai * ai + cr
        nai = ai * ar + ar * ai + ci
        {nar, nai, n - 1, cr, ci}
      end

    if n == 0 do
      Nx.tensor(1)
    else
      Nx.tensor(0)
    end
  end

  def test_julia(0, _, _, _, _), do: 1

  def test_julia(n, cr, ci, ar, ai) do
    nar = ar * ar - ai * ai + cr
    nai = ai * ar - ar * ai + ci

    if nar * nar + nai * nai > 1000 do
      0
    else
      test_julia(n - 1, cr, ci, nar, nai)
    end
  end

  def square_matrix(size) do
    range = 0..(size - 1)

    Enum.map(range, fn index ->
      Enum.map(range, &[index, &1])
    end)
  end
end

# j = Nx.divide(Nx.multiply(0.1, Nx.subtract(4, xy)), 4)

# Criar matrix dim*dim*2 de índices (x, y)
# usar os índices para calcular os valores e transformar a matriz em uma matriz de booleanos, 1 ou 0
# usar os booleanos para transformar a matriz em uma matriz de pixels [0, 0, 0, 255] ou [255, 0, 0, 255]

# para criar matriz de índices ficar de olho nas funções: iota, broadcast, concatenate, stack, tile, reshape
# x = iota axis 0, y = iota axis 1, stack x,y, reshape {3, 3, 2} (((QUASE)))

[dim] = System.argv()
dim = String.to_integer(dim)

# empty matrix setup
initial_pixel = Nx.tensor([0, 0, 0, 255], type: :f32)
initial_matrix = Nx.broadcast(initial_pixel, {dim, dim, 4}, names: [:x, :y, :pixel])
indexes = Nx.tensor(NxBenchmark.Julia.square_matrix(dim), type: :f32)

# run benchmark
started = System.monotonic_time()
result = NxBenchmark.Julia.julia(initial_matrix, indexes)
finished = System.monotonic_time()
# print result
IO.puts("Nx\t#{dim}\t#{System.convert_time_unit(finished - started, :native, :millisecond)} ")

# IO.inspect(result)
