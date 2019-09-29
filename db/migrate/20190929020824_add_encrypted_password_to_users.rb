class AddEncryptedPasswordToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_hash, :string
  end
end
