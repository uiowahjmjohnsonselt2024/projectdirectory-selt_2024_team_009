class ServerUserItem < ApplicationRecord
  belongs_to :server_user
  belongs_to :item
  validates :item_id, presence: true
end
