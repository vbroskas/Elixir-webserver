defmodule Servy.VideoCam do
  @doc """
  simulates sending a request to a external api to grab a image from a video cam
  """

  def get_snapshot(camera_name) do
    # send request to external api

    # sleep for n seconds to simulate lag in response time
    :timer.sleep(500)

    # example respose from api
    "#{camera_name}-snapshot.jpg"
  end
end
