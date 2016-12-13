class Task < ActiveRecord::Base
  belongs_to :user
  belongs_to :mission

  def children
    Task.where("parend_id = ?", self.id)
  end
end
