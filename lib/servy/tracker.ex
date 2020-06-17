defmodule Servy.Tracker do
  @doc """
  simulates sending requests to external API to get GPS coords
  """

  def get_location(animal) do
    # sleep to simulate delay in response
    :timer.sleep(500)

    # get mock geo locations
    locations = %{
      "animal1" => %{lat: "44.3344 N", lng: "110.3322 W"},
      "animal2" => %{lat: "44.3344 N", lng: "110.3322 W"},
      "animal3" => %{lat: "44.3344 N", lng: "110.3322 W"},
      "animal4" => %{lat: "44.3344 N", lng: "110.3322 W"},
      "animal5" => %{lat: "44.3344 N", lng: "110.3322 W"}
    }

    Map.get(locations, animal)
  end
end
