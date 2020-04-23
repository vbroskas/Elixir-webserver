defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  def index(conv) do
    # get and display list of bears
    items =
      Wildthings.list_bears()
      # if you want to filter for a specific group (comment out if not neede) calls is_grizzly func in bear.ex
      # |> Enum.filter(fn bear -> Bear.is_grizzly(bear) end)
      # this version uses the CAPTURE OPERATOR. the &1 is a placeholder for whatever will be passed to this function and denotes the aerity
      |> Enum.filter(&Bear.is_grizzly(&1))
      # sort by name
      # |> Enum.sort(fn bear1, bear2 -> Bear.bear_asc_by_name(bear1, bear2) end)
      |> Enum.sort(&Bear.bear_asc_by_name(&1, &2))
      # This will create a list of <li> strings
      # |> Enum.map(fn bear -> bear_item(bear) end)
      |> Enum.map(&bear_item(&1))
      # join all the individual <li> strings together into a singular string. join() returns a string of items
      |> Enum.join()

    # need to map list of bear structs into list of html items

    %{conv | status: 200, resp_body: "<ul> #{items} </ul>"}
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
