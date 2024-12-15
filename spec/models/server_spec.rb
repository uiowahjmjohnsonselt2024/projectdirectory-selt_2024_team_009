require 'rails_helper'

RSpec.describe Server, type: :model do
  let!(:player1) { Player.create(name: "Player One") }
  let!(:player2) { Player.create(name: "Player Two") }
  let!(:server1) { Server.create(name: "Server One", creator: player1) }
  let!(:server2) { Server.create(name: "Server Two", creator: player2) }

  describe "Player joining a server" do
    it "should join the correct server" do
      player1.joinServer(server1)
      expect(server1.players).to include(player1)
    end

    it "should not join a server more than once" do
      player1.joinServer(server1)
      player1.joinServer(server1)

      expect(player1.servers.where(id: server1.id).count).to eq(1)
    end
  end

  describe "Player creating a server" do
    it "should create a new server and assign it to the player" do
      new_server = Server.create(name: "Player Two's Server")

      expect(new_server).to be_persisted
      expect(new_server.creator).to eq(player2)
      expect(player2.servers).to include(new_server)
    end
  end

  describe "Player disconnecting from a server" do
    it "should remove the player from the server when they disconnect" do
      player1.joinServer(server1)
      expect(server1.players).to include(player1)

      player1.leaveServer(server1)
      expect(server1.players).not_to include(player1)
    end

    it "should not affect other players when one disconnects" do
      player1.joinServer(server1)
      player2.joinServer(server1)
      player1.leaveServer(server1)

      expect(server1.players).to include(player2)
    end
  end
end
