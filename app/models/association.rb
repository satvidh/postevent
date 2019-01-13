class Association < ActiveRecord::Base
  attr_accessible :user_id, :nonce, :expired
  validates :user_id, :presence => true
  validates :nonce, :presence => true, :uniqueness => true
  # DO NOT VALIDATE expired because it is a boolan.
end
