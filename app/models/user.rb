class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :missions
  has_many :tasks
  has_many :skils
  has_many :comments
  has_many :attachments
end
