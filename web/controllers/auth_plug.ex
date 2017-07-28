defmodule Geminiex.AuthPlug do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> attempted_auth] -> verify(conn, attempted_auth, repo)
      _                            -> unauthorized(conn)
    end
  end

  defp verify(conn, attempted_auth, repo) do
    case Base.decode64(attempted_auth) do
      {:ok, decoded_auth} ->
        case String.split(decoded_auth, ":") do
          [key | _pass] ->
            account = repo.get_by!(Geminiex.Account, key: key)
            assign(conn, :account, account)
          _ ->
            unauthorized(conn)
        end
      _ ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
      |> send_resp(401, "unauthorized")
      |> halt()
  end
end