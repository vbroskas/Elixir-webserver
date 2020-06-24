defmodule PledgeServerTest do
  use ExUnit.Case
  alias Servy.PledgeServer

  test "server caches only the 3 most recent pledges and totals their amounts" do
    pid = PledgeServer.start()

    PledgeServer.create_pledge("joe", 5)
    PledgeServer.create_pledge("ted", 10)
    PledgeServer.create_pledge("moe", 15)
    PledgeServer.create_pledge("bob", 20)
    PledgeServer.create_pledge("sam", 25)
    PledgeServer.create_pledge("cue", 30)

    # IO.puts("\n-----------------------------")
    PledgeServer.recent_pledges()
    PledgeServer.total_pledged()

    assert PledgeServer.recent_pledges() == [{"cue", 30}, {"sam", 25}, {"bob", 20}]
    assert PledgeServer.total_pledged() == 105
  end
end
