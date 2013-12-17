class User < ActiveRecord::Base
	SALT = 'luck'
	validates :name, :presence => true
	validates :password, :length => {:minimum => 6}, :presence => true
    validates :email, :length => {:minimum => 6}, :presence => true, :uniqueness => true
	has_many :posts, :dependent => :destroy

    def Error
    	
    end

end