defmodule Aquamarine.Factory do
  use ExMachina.Ecto, repo: Aquamarine.Repo
  use Aquamarine.Factories.{UserFactory}
end
