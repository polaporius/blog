class User < ActiveRecord::Base
	SALT = 'luck'
	attr_accessor :password_second
	validates :name, :presence => true
	validates :password, :length => {:minimum => 6}, :presence => true
    validates :email, :length => {:minimum => 6}, :presence => true, :uniqueness => true
	has_many :posts, :dependent => :destroy

	before_save :encrypt_password
	validate :check_passwords_equality

	def self.is_persisted? email
		User.find_by_email email 	
	end

	private

	def encrypt_password 
		self.password = Digest::SHA2.hexdigest(password + SALT)
	end

	def check_passwords_equality 
		errors[:password] = 'must equals to second password' unless password == password_second
	end

end