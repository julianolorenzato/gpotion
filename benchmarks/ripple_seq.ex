defmodule BMP do
  @on_load :load_nifs
  def load_nifs do
      :erlang.load_nif('./priv/bmp_nifs', 0)
  end
  def gen_bmp_nif(_string,_dim,_mat) do
      raise "gen_bmp_nif not implemented"
  end
  def gen_bmp(string,dim,%Matrex{data: matrix} = _a) do
    gen_bmp_nif(string,dim,matrix)
  end
end

defmodule Ripple do
  def gen_pixel(ptr,dim,ticks,{y,x}) do
    offset = x + (y * dim)
    fx = 0.5 *  x - dim/15;#x - dim/2;
    fy = 0.5 *  y - dim/15;#y - dim/2;
    d  = :math.sqrt( fx * fx + fy * fy );
    grey = floor(128.0 + 127.0 * :math.cos(d/10.0 - ticks/7.0) /(d/10.0 + 1.0));

    ptr
    |> Matrex.set(1, offset*4 + 1, grey)
    |> Matrex.set(1, offset*4 + 2, grey)
    |> Matrex.set(1, offset*4 + 3, grey)
    |> Matrex.set(1, offset*4 + 4, 255)
  end
  def ripple_seq(ptr,dim, ticks, [{y,x}]) do
    gen_pixel(ptr,dim, ticks, {y,x})
  end
  def ripple_seq(ptr, dim,ticks ,[{y,x}|tail]) do
    narray = gen_pixel(ptr,dim,ticks, {y,x})
    ripple_seq(narray,dim,ticks, tail)
  end
end

[arg] = System.argv()

user_value = String.to_integer(arg)

dim = user_value

mat = Matrex.fill(1,dim*dim*4,0)


indices = for i <- Enum.to_list(0..(dim-1)), j<-Enum.to_list(0..(dim-1)), do: {i,j}

prev = System.monotonic_time()
imageseq = Ripple.ripple_seq(mat,dim,10,indices)
next = System.monotonic_time()
IO.puts "Elixir\t#{user_value}\t#{System.convert_time_unit(next-prev,:native,:millisecond)}"

BMP.gen_bmp('rippleseq.bmp',dim,imageseq)
