defmodule Aquamarine.Factories.PlaceFactory do
  defmacro __using__(_opts) do
    quote do
      def place_factory do
        %Aquamarine.Vacations.Place{
          name: sequence(:name, &"name_#{&1}"),
          slug: sequence(:slug, &"slug-#{&1}"),
          description: "description",
          location: "location",
          price_per_night: Decimal.new("100.00"),
          image: "image_url",
          image_thumbnail: "image_thumbnail_url",
          max_guests: 3,
          pet_friendly: true,
          pool: true,
          wifi: true
        }
      end
    end
  end
end
