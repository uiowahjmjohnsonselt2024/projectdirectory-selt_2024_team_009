require 'rails_helper'

RSpec.describe Score, type: :model do
  describe 'Validations' do
    it 'is valid with valid attributes' do
      user = User.create(username: 'Player1', email: 'player1@example.com', password: 'password123')
      server = Server.create(name: 'Test Server')
      score = Score.new(user: user, server: server, value: 100)

      expect(score).to be_valid
    end


  end

  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:server) }
  end

end
