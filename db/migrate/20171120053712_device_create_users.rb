# coding: utf-8
class DeviceCreateUsers < ActiveRecord::Migration[4.2]
  def change
    
    ## 認証トークン
    add_column :users, :authentication_token, :string
    add_index :users, :authentication_token, unique: true
  end
end
