class CreateComments < ActiveRecord::Migration
  def self.up
  	create_table :comments do |t|
      t.text :body
      t.timestamps
      t.integer :post_id
      t.string :user_name
      t.references :user
      t.references :post
    end
  end

  def self.down
  	drop_table :comments
  end
end
