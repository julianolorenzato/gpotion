Mix.install([{:exla, "~> 0.6.4"}])

Nx.global_default_backend(EXLA.Backend)

defmodule NN do
  import Nx.Defn

  defn euclid(tensor, lat, lng) do
    case Nx.shape(tensor) do
      {2} -> :ok
      _ -> raise "invalid shape"
    end

    m_lat = tensor[0]
    m_lng = tensor[1]

    value = Nx.sqrt((lat - m_lat) * (lat - m_lat) + (lng - m_lng) * (lng - m_lng))

    value
  end
end
