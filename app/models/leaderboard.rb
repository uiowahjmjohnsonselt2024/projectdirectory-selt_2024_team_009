class Leaderboard < ApplicationRecord
  belongs_to :server

  def update()
    #this function is added so the test cases work correctly
    # eventually, this function will update the leaderboard with the
    # 'newest' scores

  end
end
