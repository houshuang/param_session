defmodule ParamSessionTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Plug.Conn
  import ParamSessionTestHelper

  alias Plug.Session.COOKIE
  @opts ParamSession.init([])

  test "encode -> decode works (raw functions)" do
    opts = ParamSession.cookieopts
    conn = sane_conn
    |> ParamSession.call(@opts)
    |> Conn.put_session(:test, 123)
    conn2 = sane_conn
    |> ParamSession.call(@opts)

    encode = COOKIE.put(conn, [], conn.private.plug_session, opts)
    {nil, decode} = COOKIE.get(conn2, encode, opts)
    assert decode["test"] == 123
  end

  test "encode -> decode works (my functions)" do
    conn = sane_conn
    |> ParamSession.call(@opts)
    |> Conn.put_session(:test, 123)
    conn2 = sane_conn

    encode = ParamSession.gen_cookie(conn)
    decode = ParamSession.string_to_session(conn2, encode)
    assert decode != %{}
    assert decode["test"] == 123
  end

  test "simple param is passed through" do
    # generate session URL
    conn = sane_conn
    |> ParamSession.call(@opts)
    conn = Conn.put_session(conn, :test, 123)
    url = ParamSession.gen_url(conn, "/")
    assert String.contains?(url, "session")

    conn = sane_conn(url)
    |> ParamSession.call(@opts)
    assert Conn.get_session(conn, :test) == 123
  end

  test "link generation works with pre-existing params (and they are preserved)" do
    # generate session URL
    conn = sane_conn
    |> ParamSession.call(@opts)
    conn = Conn.put_session(conn, :test, 123)
    url = ParamSession.gen_url(conn, "/?age=21&name=stian")
    assert String.contains?(url, "session")

    conn = sane_conn(url)
    |> ParamSession.call(@opts)
    assert Conn.get_session(conn, :test) == 123
    assert conn.params["age"] == "21"
    assert conn.params["name"] == "stian"
  end

  test "no session -> no param" do
    conn = sane_conn
    |> ParamSession.call(@opts)
    
    formhelper = ParamSession.form_session(conn)
    assert !String.contains?(formhelper, "session")
  end

  test "form params work" do
    conn = sane_conn
    |> ParamSession.call(@opts)
    |> Conn.put_session(:test, 123)
    |> Conn.put_session(:second, "alpha")
    
    formhelper = ParamSession.form_session(conn)
    assert String.contains?(formhelper, "session")
    # todo - how to simulate post request with form body in testing?
  end
end
