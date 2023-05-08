class RemoveNameNullConstraintFromUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_null :users, :name, true
  end
end
