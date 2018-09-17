defmodule Snackex.Storage do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  defp exists?(group, elem) do
    Agent.get(__MODULE__, fn elems ->
      Enum.member?(Map.get(elems, group, []), elem)
    end)
  end

  defp insert(group, elem) do
    Agent.update(__MODULE__, fn elems -> 
      Map.update(elems, group, [elem], fn users -> [elem | users] end)
    end)
  end

  def insert(group, user, snack) do
    elem = {user, snack}
    case exists?(group, elem) do
      :false ->
        insert(group, elem)
        :true
      :true ->
        :false
    end
  end

  def clean(group) do
    Agent.update(__MODULE__, fn elems -> 
      Map.update(elems, group, [], fn _ -> [] end)
    end)
  end

  def get(group, user_id) do
    Agent.get(__MODULE__, fn elems -> 
      Enum.find(Map.get(elems, group, []), fn {user, _} ->
        user.user_id == user_id
      end)
    end)
  end

  def get_all(group) do
    Agent.get(__MODULE__, fn elems ->
      Map.get(elems, group, [])
    end)
  end
end
