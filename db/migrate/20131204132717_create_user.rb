class CreateUser < ActiveRecord::Migration
  def up
    create_table :users do |u|
      u.string :name
      u.string :password
      u.string :email
    end
  end

  def down
    drop_table :users
  end
end
