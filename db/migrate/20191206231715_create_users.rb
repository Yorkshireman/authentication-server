class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, unique: true, index: true, null: false
      t.string :name, null: false
      t.string :password_digest, null: false

      t.timestamps
    end
  end
end
