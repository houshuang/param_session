defmodule ParamSessionTestHelper do
  @parseropt Plug.Parsers.init(parsers: [:urlencoded], pass: ["*/*"])
  @secret_key_base :crypto.rand_bytes(64) |> Base.encode64
  use Plug.Test
  alias Plug.Conn
  ExUnit.start()

  def sane_conn(url \\ "/") do
    conn(:get, url) 
    |> Map.put(:secret_key_base, @secret_key_base)
    |> Conn.fetch_query_params
    |> Plug.Parsers.call(@parseropt)
  end
end
