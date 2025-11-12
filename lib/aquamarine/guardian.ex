defmodule Aquamarine.Guardian do
  use Guardian, otp_app: :aquamarine

  @impl true
  def subject_for_token(%{id: id}, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it is being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _), do: {:error, :invalid_subject}

  @impl true
  def resource_from_claims(%{"sub" => id}) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In above `subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    case Aquamarine.Accounts.get_user(id) do
      nil -> {:error, :record_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_claims), do: {:error, :invalid_claims}

  @impl true
  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  @impl true
  def on_verify(claims, token, options) do
    if false == Keyword.get(options, :on_verify) do
      {:ok, claims}
    else
      do_on_verify(claims, token, options)
    end
  end

  defp do_on_verify(%{"typ" => "refresh"} = claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  defp do_on_verify(claims, _token, _options), do: {:ok, claims}

  @impl true
  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  @impl true
  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end

  def access_token_ttl do
    {
      System.get_env("GUARDIAN_ACCESS_TOKEN_TTL_VALUE") |> String.to_integer(),
      System.get_env("GUARDIAN_ACCESS_TOKEN_TTL_UNIT") |> String.to_atom()
    }
  end

  def refresh_token_ttl do
    {
      System.get_env("GUARDIAN_REFRESH_TOKEN_TTL_VALUE") |> String.to_integer(),
      System.get_env("GUARDIAN_REFRESH_TOKEN_TTL_UNIT") |> String.to_atom()
    }
  end
end
