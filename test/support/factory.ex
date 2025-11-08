defmodule Aquamarine.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Aquamarine.Repo
  use Aquamarine.Factories.{UserFactory, PlaceFactory, ReviewFactory, BookingFactory}
end
