class CreateAssociations < ActiveRecord::Migration
  def change
    create_table :associations do |t|
      t.string :user_id
      t.string :nonce
      t.boolean :expired

      t.timestamps
    end
  end
end
