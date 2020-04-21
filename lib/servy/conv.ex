defmodule Servy.Conv do
  # name of a struc is the same as the module, this is why a struc must live in a module
  # and you cant define more than one struct per module!
  # structs have a keyword list
  defstruct method: "",
            path: "",
            resp_body: "",
            status: nil,
            protocol: "",
            params: %{},
            headers: %{}

  def full_status(conv) do
    "#{conv.protocol} #{conv.status} #{status_reason(conv.status)}"
  end

  # declare private that can only be called in module they're defined in
  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end
