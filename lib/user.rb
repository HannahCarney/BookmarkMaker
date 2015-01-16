require 'bcrypt'
require 'pony'
require 'secret_files'
class User

  include DataMapper::Resource

  property :id, Serial
  property :email, String, :unique => true
  property :password_digest, Text
  property :password_token,  Text
  property :password_token_timestamp, Time

	attr_reader :password
	attr_accessor :password_confirmation
	
	validates_confirmation_of :password
  validates_uniqueness_of :email

  def password=(password)
  	@password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def self.authenticate(email, password)
    user = first(:email => email)
    if user && BCrypt::Password.new(user.password_digest) == password
      user
    else
      nil
    end
  end

  def create_token
    (1..64).map{('A'..'Z').to_a.sample}.join
  end

  def send_email(email)
      Pony.mail({
       :from => 'bookmarkmanager@gmail.com',
       :to => @email,
       :subject => " has contacted you",
       :body => "Please follow the link: \"/users/reset_password/#{@password_token}\" to change your password. You have untill #{Time.now+(60*60)}",
       :via => :smtp,
       :via_options => {
         :address              => 'smtp.gmail.com',
         :port                 => '587',
         :enable_starttls_auto => true,
         :user_name            => $email,
         :password             => $password,
         :authentication       => :plain,
         :domain => 'localhost.localdomain'
        }
       })
    end
end