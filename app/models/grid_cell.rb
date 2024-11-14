class GridCell < ApplicationRecord
  belongs_to :server
  belongs_to :content
  belongs_to :treasure
end
