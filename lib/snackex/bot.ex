defmodule Snackex.Bot do
  @bot_name :snackex_bot
  def bot(), do: @bot_name

  use Telex.Bot, name: @bot_name
  use Telex.Dsl

  require Logger

  def handle({:command, "order", %{chat: %{id: chat_id, type: "group"}, text: text, from: %{first_name: first_name, id: user_id}}}, _name, _extra) do
    username = first_name
    Logger.info("#{username} (#{user_id}) has ordered '#{text}'")
    user = %Snackex.User{username: username, user_id: user_id}
    snack = %Snackex.Snack{name: text}
    case Snackex.Storage.insert(chat_id, user, snack) do
      :true ->
        answer("#{username}, I take note of that!")
      :false ->
        answer("#{username}, you already ordered!")
    end
  end

  def handle({:command, "see", %{chat: %{id: chat_id, type: "group"}, from: %{first_name: first_name, id: user_id}}}, _name, _extra) do
    username = first_name
    case Snackex.Storage.get(chat_id, user_id) do
      {_, snack} ->
        answer("#{username}, you have ordered #{snack.name}.")
      nil ->
        answer("#{username}, you have not ordered anything yet!")
    end
  end

  def handle({:command, "ticket", %{chat: %{id: chat_id, type: "group"}}}, _name, _extra) do
    Logger.info("Generating ticket for room #{chat_id}!")

    orders = Enum.map(Snackex.Storage.get_all(chat_id), fn {user, snack} ->
      "#{user.username} has ordered #{snack.name}"
    end)
  
    tickets = Enum.reduce(orders, fn x, acc -> 
      x <> "\n" <> acc
    end)

    answer(tickets)
  end

  def handle({:command, "clean", %{chat: %{id: chat_id, type: "group"}}}, _name, _extra) do
    Logger.info("Cleaning orders for room #{chat_id}!")
    case Snackex.Storage.clean(chat_id) do
      :ok ->
        answer("All clear!")
      _ ->
        answer("Something went wrong!")
    end
  end
end
