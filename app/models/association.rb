class Association < ActiveRecord::Base
  attr_accessible :user_id, :nonce
  validates :user_id, :presence => true
  validates :nonce, :presence => true, :uniqueness => true
end
