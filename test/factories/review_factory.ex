defmodule Aquamarine.Factories.ReviewFactory do
  defmacro __using__(_opts) do
    quote do
      def review_factory do
        %Aquamarine.Vacations.Review{
          rating: 1..5 |> Enum.random(),
          comment: Faker.Lorem.paragraph(),
          place: build(:place),
          user: build(:user)
        }
      end
    end
  end
end
