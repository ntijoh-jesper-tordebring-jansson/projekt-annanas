defmodule Pluggy.Router do
  use Plug.Router
  use Plug.Debugger

  alias Pluggy.PizzaController
  alias Pluggy.FruitController
  alias Pluggy.UserController
  alias Pluggy.AdminController

  plug(Plug.Static, at: "/", from: :pluggy)
  plug(:put_secret_key_base)

  plug(Plug.Session,
  store: :cookie,
  key: "_my_app_session",
  encryption_salt: "cookie store encryption salt",
  signing_salt: "cookie store signing salt",
  log: :debug
)

  plug(:fetch_session)
  plug(Plug.Parsers, parsers: [:urlencoded, :multipart])
  plug(:match)
  plug(:dispatch)

  get("/", do: PizzaController.index(conn))
  get("/admin", do: AdminController.admin(conn))
  get("/admin/orders", do: AdminController.orders(conn))
  get("/menu", do: PizzaController.menu(conn))
  get("/menu/edit/:id", do: PizzaController.edit(conn, id))
  get("/fruits", do: FruitController.index(conn))
  get("/fruits/new", do: FruitController.new(conn))
  get("/fruits/:id", do: FruitController.show(conn, id))
  get("/fruits/:id/edit", do: FruitController.edit(conn, id))

  get("/checkout", do: PizzaController.checkout(conn))

  post("/menu/edit/:id", do: PizzaController.update(conn, id, conn.body_params))

  post("/fruits", do: FruitController.create(conn, conn.body_params))

  # should be put /fruits/:id, but put/patch/delete are not supported without hidden inputs
  post("/fruits/:id/edit", do: FruitController.update(conn, id, conn.body_params))

  # should be delete /fruits/:id, but put/patch/delete are not supported without hidden inputs
  post("/fruits/:id/destroy", do: FruitController.destroy(conn, id))

  post("/users/login", do: UserController.login(conn, conn.body_params))
  post("/users/logout", do: UserController.logout(conn))

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp put_secret_key_base(conn, _) do
    put_in(
      conn.secret_key_base,
      "M7K/Odlu5j46AZslaMS+Xm02LvTemMXnRcPmBVqnzM1rxKW7JFR9I5o8tw6dl8fYUJLT1ie/nBejkXNU1VwA6w=="
    )
  end
end
