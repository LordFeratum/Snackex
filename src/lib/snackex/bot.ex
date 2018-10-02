defmodule Snackex.Bot do
  @bot_name :snackex_bot
  def bot(), do: @bot_name

  use Telex.Bot, name: @bot_name
  use Telex.Dsl

  require Logger

  def handle({:command, "order", %{chat: %{id: chat_id}, text: text, from: %{first_name: first_name, id: user_id}}}, _name, _extra) do
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

  def handle({:command, "see", %{chat: %{id: chat_id}, from: %{first_name: first_name, id: user_id}}}, _name, _extra) do
    username = first_name
    case Snackex.Storage.get(chat_id, user_id) do
      [] ->
        answer("#{username}, you have not ordered anything yet!")
      tickets ->
        answer(show_tickets(tickets))
    end
  end

  def handle({:command, "ticket", %{chat: %{id: chat_id}}}, _name, _extra) do
    Logger.info("Generating ticket for room #{chat_id}!")

    tickets = show_tickets(Snackex.Storage.get_all(chat_id))
    answer(tickets)
  end

  def handle({:command, "clean", %{chat: %{id: chat_id}}}, _name, _extra) do
    Logger.info("Cleaning orders for room #{chat_id}!")
    case Snackex.Storage.clean(chat_id) do
      :ok ->
        answer("All clear!")
      _ ->
        answer("Something went wrong!")
    end
  end

  def handle({:command, _cmd, data}, _name, _extra) do
    Logger.info("No handle defined! --> #{data}")
    answer("Sorry, I can't understand you.")
  end

  defp show_tickets(tickets) do
    orders = Enum.map(tickets, fn {user, snack} ->
      "#{user.username} --> #{snack.name}"
    end)
  
    Enum.reduce(orders, fn x, acc -> 
      x <> "\n" <> acc
    end)
  end
end
