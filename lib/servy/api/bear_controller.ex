defmodule Servy.Api.BearController do
  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!()

    conv = put_resp_content_type(conv, "application/json")

    # update/change resp_content_type to be "application/json", instead of the default "text/html" which we set in conv.ex
    %{conv | status: 200, resp_body: json}
  end

  def put_resp_content_type(conv, content_type) do
    headers = Map.put(conv.resp_headers, "content_type", content_type)
    %{conv | resp_headers: headers}
  end

  def create(conv, %{"name" => name, "type" => type}) do
    conv = put_resp_content_type(conv, "text/html")

    %{
      conv
      | status: 201,
        resp_body: "Created a #{type} bear named #{name}!"
    }
  end
end
