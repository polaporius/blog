class Comment < ActiveRecord::Base
    validates :body, presence: true
    validates :title, presence: true, length: { minimum: 3 }
	belongs_to :post
	belongs_to :user
end