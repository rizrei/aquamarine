defmodule Aquamarine.Factories.UserFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Aquamarine.Accounts.User{
          name: sequence(:name, &"name_#{&1}"),
          email: sequence(:email, &"email-#{&1}@example.com"),
          password: "Passw0rd",
          password_hash: Bcrypt.hash_pwd_salt("Passw0rd")
        }
      end
    end
  end
end
