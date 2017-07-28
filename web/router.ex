defmodule Geminiex.Router do
  use Geminiex.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Geminiex do
    pipe_through :api

    get "/crop", EntriesController, :crop
  end
end
