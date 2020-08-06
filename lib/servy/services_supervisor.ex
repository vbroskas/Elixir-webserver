defmodule Servy.ServicesSupervisor do
  use Supervisor

  # find and kill a server...
  # Process.whereis(:sensor_server) |> Process.exit(:kill)

  # using the pid returned by {:ok, sup_pid} = Servy.ServicesSupervisor.start_link()..
  # get all children for a supervisor...
  # Supervisor.which_children(sup_pid)

  def start_link do
    IO.puts("starting Services supervisor...")
    # start_link spawns a supervisor process and LINKS it to the process that calls start_link()
    # start_link(module, init_arg, options \\ [])...__MODULE__ is our callback module
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # init is where we tell the Supervisor process what children processes it needs to monitor
    # when a child process is started, it needs to be linked to the supervisor so the supervisor can detect a crash
    # as a default, the supervisor process assumes a child process defines a start_link() function...
    children = [Servy.PledgeServer, {Servy.SensorServer, 3}, Servy.FourOhFourCounter]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
