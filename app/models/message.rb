class Message < ApplicationRecord
  belongs_to :user
  belongs_to :game, optional: true
end
