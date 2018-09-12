class DropAttachment < ActiveRecord::Migration
  def change
	  drop_table :attachments
  end
end
