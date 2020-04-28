defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear

  @template_dir_path Path.expand("../../templates", __DIR__)

  def index(conv) do
    # get and display list of bears
    bears =
      Wildthings.list_bears()
      # |> Enum.sort(fn bear1, bear2 -> Bear.bear_asc_by_name(bear1, bear2) end)
      |> Enum.sort(&Bear.bear_asc_by_name(&1, &2))

    # create content from templates to attach to response body
    content =
      @template_dir_path
      |> Path.join("index.eex")
      |> EEx.eval_file(bears: bears)

    %{conv | status: 200, resp_body: content}
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    %{conv | status: 200, resp_body: "<h1>Bear called: #{bear.name} with ID: #{bear.id}</h1>"}
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
