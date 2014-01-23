class CreateComment < ActiveRecord::Migration
  def up
    create_table :comments do |c|
      c.string :title
      c.text :body
      c.timestamps
      c.string :user_name
      c.references :user
      c.references :post
    end
  end

  def down
    drop_table :comments
  end
end
