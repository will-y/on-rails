class Schedule
  include Mongoid::Document

  before_save :encrypt_password

  validates :name, presence: true

  attr_accessor :password

  field :name, type: String
  field :username, type: String
  field :encrypted_password, type: String
  field :phone, type: String
  field :email

  def self.authenticate(username, password)
    user = User.where(username: username).first
    return user && user.encrypted_password == password.crypt("$5$round=7845$salt$")
  end

  def encrypt_password
    self.encrypted_password = password.crypt("$5$round=7845$salt$")
    puts encrypted_password
  end
end
