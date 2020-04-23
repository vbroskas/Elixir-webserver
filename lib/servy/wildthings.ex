defmodule Servy.Wildthings do
  alias Servy.Bear

  '''
  this file provides extraction for fetching any of our "wild/animal resources"
  '''

  def list_bears do
    [
      %Bear{id: 1, name: "Teddy", type: "Brown", hibernating: true},
      %Bear{id: 2, name: "Smokey", type: "Black"},
      %Bear{id: 3, name: "Paddington", type: "Brown"},
      %Bear{id: 4, name: "Scarface", type: "Grizzly", hibernating: true},
      %Bear{id: 5, name: "Snow", type: "Polar"},
      %Bear{id: 6, name: "Brutus", type: "Grizzly"},
      %Bear{id: 7, name: "Rosie", type: "Black", hibernating: true},
      %Bear{id: 8, name: "Roscoe", type: "Panda"},
      %Bear{id: 9, name: "Iceman", type: "Polar", hibernating: true},
      %Bear{id: 10, name: "Kenai", type: "Grizzly"}
    ]
  end

  # use guard clause to ensure the id passed to this function is an integer
  def get_bear(id) when is_integer(id) do
    # use  Enum.find, feed in mater list of bears, and then inline function that looks at each bear and if its id matches the id passed
    # to get_bear then return it
    Enum.find(list_bears(), fn bear -> bear.id == id end)
  end

  # use guard to check if id in string. convert string id to int and then pass to primary get_bear function
  def get_bear(id) when is_binary(id) do
    id |> String.to_integer() |> get_bear()
  end
end
