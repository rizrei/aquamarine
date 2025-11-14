# Example .env file
# Create ~/config/.env.exs or ~/config/.env.dev.exs and ~/config/.env.test.exs
# and set your own parameters
System.put_env("DB_PORT", "")
System.put_env("GUARDIAN_SECRET_KEY", "")
System.put_env("GUARDIAN_ACCESS_TOKEN_TTL_VALUE", "10")
System.put_env("GUARDIAN_ACCESS_TOKEN_TTL_UNIT", "minutes")
System.put_env("GUARDIAN_REFRESH_TOKEN_TTL_VALUE", "30")
System.put_env("GUARDIAN_REFRESH_TOKEN_TTL_UNIT", "days")
System.put_env("GUARDIAN_DB_SWEEP_INTERVAL", :timer.hours(1) |> to_string())
