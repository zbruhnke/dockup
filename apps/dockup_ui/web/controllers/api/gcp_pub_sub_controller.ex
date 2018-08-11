defmodule DockupUi.API.GcpPubSubController do
  use DockupUi.Web, :controller
  alias DockupUi.Triggers.GoogleCloudBuild

   # {
   #   "message": {
   #     "attributes": {
   #       "buildId": "abcd-efgh...",
   #       "status": "SUCCESS"
   #     },
   #     "data": "SGVsbG8gQ2xvdWQgUHViL1N1YiEgSGVyZSBpcyBteSBtZXNzYWdlIQ==",
   #     "message_id": "136969346945"
   #   },
   #   "subscription": "projects/myproject/subscriptions/mysubscription"
   # }
  def create(conn, %{"message" => %{"attributes" => _attributes, "data" => data}}) do
    GoogleCloudBuild.handle(data)

    conn
    |> put_status(:ok)
    |> text("ok")
  end
end
