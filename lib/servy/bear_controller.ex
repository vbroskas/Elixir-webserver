defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  import Servy.View, only: [render: 3]

  def index(conv) do
    # get and display list of bears
    bears =
      Wildthings.list_bears()
      # |> Enum.sort(fn bear1, bear2 -> Bear.bear_asc_by_name(bear1, bear2) end)
      |> Enum.sort(&Bear.bear_asc_by_name(&1, &2))

    # create content from templates to attach to response body
    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{
      conv
      | status: 201,
        resp_body: "New bear called: #{name} of type: #{type} created!"
    }
  end

  def delete(conv, %{"id" => id}) do
    %{conv | status: 403, resp_body: "CANNOT Deleted Bear #{id}"}
  end
end
