defmodule Servy.FileHandler do
  @spec handle_file({:error, any} | {:ok, any}, %{resp_body: any, status: any}) :: %{
          resp_body: any,
          status: 200 | 404 | 500
        }
  def handle_file({:ok, content}, conv) do
    # return updated conv map to the next function in primary pipeline
    %{conv | status: 200, resp_body: content}
  end

  # Failure not found case: Takes in tuple and conv. Will take in and match on the tuple returned by File.read()
  def handle_file({:error, :enoent}, conv) do
    %{conv | status: 404, resp_body: "File not found!"}
  end

  # Failure catch-all case: Takes in tuple and conv. Will take in and match on the tuple returned by File.read()
  def handle_file({:error, reason}, conv) do
    %{conv | status: 500, resp_body: "Error! #{reason}"}
  end
end
