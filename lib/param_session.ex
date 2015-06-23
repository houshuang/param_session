defmodule ParamSession do
  use Behaviour
  @behaviour Plug
  require Logger

  alias Plug.Session.COOKIE
  alias Plug.Conn

  # we use a module parameter instead of the init() function, because
  # we need this value accessible not only when the plug is called through
  # call(), but also when the other functions are called directly
  @opts COOKIE.init Application.get_all_env(:param_session) 
  def cookieopts, do: @opts

  def init(_) do
  end

  # checks for a session parameter, and if it exists, decodes, verifies, 
  # and attaches to the conn element, making it available for
  # get_session and put_session
  def call(conn, _) do
    if sessionenc = conn.params["session"] do
      session = string_to_session(conn, sessionenc)
    else
      session = %{}
    end

    conn
    |> Conn.put_private(:plug_session, session)
    |> Conn.put_private(:plug_session_fetch, :done)
  end

  def string_to_session(conn, str) do
    str = str
    |> String.replace("-", "+")
    |> String.replace("_", "/")
    |> String.replace(".", "=")
    |> Base.decode64!
    case COOKIE.get(conn, str, @opts) do
      {_, session} -> session
    end
  end

  # generates the param string if any session parameters have been set with
  # put_session
  def gen_cookie(conn) do
    if !Enum.empty?(conn.private[:plug_session]) do
      COOKIE.put(conn, [], conn.private.plug_session, @opts)
      |> Base.encode64
      |> String.replace("+", "-")
      |> String.replace("/", "_")
      |> String.replace("=", ".")
    else
      :none
    end
  end

  # insert the result of this function in the body of a form
  #
  # example for Phoenix eex template:
  #
  # <%= form_for @conn, user_path(@conn, :submit), [name: :search], fn _ -> %>
  # <%= raw ParamSession.form_session @conn %>
  def form_session(conn) do
    case gen_cookie(conn) do
      :none -> ""
      x -> "<input name='session' type='hidden' value='#{x}'>"
    end
  end

  # attaches cookie value as a param to a URL. should handle cases where
  # there are already URL parameters present
  def gen_url(conn, url) do
    sepchar = if String.contains?(url, "?") do
      "&"
    else
      "?"
    end
    url <> sepchar <> "session=" <> gen_cookie(conn)
  end

  # redirects conn to a new URL, with the session attached
  # adapted from Phoenix.Controller.Redirect to avoid having Phoenix as a
  # dependency
  def redirect(conn, to) do
    url  = gen_url(conn, to)
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">
    redirected</a>.</body></html>"

    conn
    |> Conn.put_resp_header("location", url)
    |> Conn.send_resp(302, body)
  end
end

