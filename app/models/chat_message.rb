class ChatMessage < ApplicationRecord
  belongs_to :server
  belongs_to :user
  validates :content, presence: true

end
