defmodule Geminiex.FallbackController do
  use Geminiex.Web, :controller

  def call(conn, {:error, :not_found}) do
    conn
      |> send_resp(404, "Cant find source")
      |> halt()
  end

  def call(conn, {:error, :invalid_request}) do
    conn
      |> send_resp(400, "Bad request")
      |> halt()
  end
end