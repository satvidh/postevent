class AddUserIdToPosts < ActiveRecord::Migration
  def change
  	add_column :users, :slack_user_id, :string
  	add_column :users, :slack_association_nonce, :string
  end
end
