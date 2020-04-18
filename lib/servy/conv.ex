defmodule Servy.Conv do
  # name of a struc is the same as the module, this is why a struc must live in a module
  # and you cant define more than one struct per module!
  # structs have a keyword list
  defstruct method: "", path: "", resp_body: "", status: nil, version: ""
end
