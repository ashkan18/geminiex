ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Geminiex.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Geminiex.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Geminiex.Repo)

