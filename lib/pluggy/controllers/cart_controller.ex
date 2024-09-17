defmodule Pluggy.CartController do
  alias Pluggy.Pizza

  require IEx

  alias Pluggy.Cart
  import Pluggy.Template, only: [render: 3, render: 2]
  import Plug.Conn, only: [send_resp: 3]

  def add(conn, params) do
    Cart.add_cart(conn, params)
    redirect(conn, "/menu")
  end

  def add_edit(conn, id, params) do
    Cart.add_edit_cart(conn, id, params)
    redirect(conn, "/menu")
  end

  def remove(conn, params) do
    id_str = params["id"]
    IO.inspect(params)
    id = String.to_integer(id_str)
    IO.puts("Removing from cart")
    Postgrex.query!(DB, "DELETE FROM carts WHERE id = $1", [id])
    redirect(conn, "/menu")
  end

  def submit_order(conn, params) do
    cart = Cart.all(conn)
    customer = params["checkout_name"]
    user_uuid = conn.private.plug_session["cart"]
    IO.puts("Submitting order")

    for pizza <- cart do
      Postgrex.query!(
        DB,
        "INSERT INTO orders(pizza_name, added_ingredients, removed_ingredients, customer, is_done, size, gluten) VALUES($1, $2, $3, $4, $5, $6, $7)",
        [
          pizza.pizza_name,
          pizza.add_ingredients,
          pizza.remove_ingredients,
          customer,
          false,
          pizza.size,
          pizza.gluten
        ]
      )
    end

    Postgrex.query!(DB, "DELETE FROM carts WHERE uuid = $1", [user_uuid])

    send_resp(
      conn,
      200,
      render(conn, "pizzas/order_confirmation", pizzas: Pizza.all())
    )
  end

  defp redirect(conn, url),
    do: Plug.Conn.put_resp_header(conn, "location", url) |> send_resp(303, "")
end
