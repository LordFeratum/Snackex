defmodule Snackex.User do
  @enforce_keys [:username, :user_id]
  defstruct [:username, :user_id]
end
