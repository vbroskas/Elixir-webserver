defmodule UserApi do
  def query_id(id) do
    api_url(id)
    # this will return a tuple {status, response}, we will match for various cases in process_response()
    |> HTTPoison.get()
    |> process_response
  end

  defp api_url(id) do
    "https://jsonplaceholder.typicode.com/users/#{URI.encode(id)}"
  end

  # status_code 200 OK case
  defp process_response({:ok, %{status_code: 200, body: body}}) do
    email =
      Poison.Parser.parse!(body, %{})
      |> get_in(["email"])

    city =
      Poison.Parser.parse!(body, %{})
      |> get_in(["address", "city"])

    {:ok, city, email}
  end

  # any status_code other than 200 case
  defp process_response({:ok, %{status_code: _status, body: body}}) do
    message =
      Poison.Parser.parse!(body, %{})
      |> get_in(["message"])

    {:error, message}
  end

  # query error case
  defp process_response({:error, %{reason: reason}}) do
    {:error, reason}
  end
end
