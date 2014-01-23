class Post < ActiveRecord::Base
  validates :title, presence: true, length: { minimum: 3 }
  validates :body, presence: true
  belongs_to :user
  has_many :comments, :dependent => :destroy
  
  def user_name
  	user.name
  end
end