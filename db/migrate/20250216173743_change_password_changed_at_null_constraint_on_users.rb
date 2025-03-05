class ChangePasswordChangedAtNullConstraintOnUsers < ActiveRecord::Migration[6.0]
  def change
    execute 'UPDATE users SET password_changed_at = created_at WHERE password_changed_at IS NULL'
    change_column_null :users, :password_changed_at, false
  end
end
