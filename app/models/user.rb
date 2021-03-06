class User
  include Mongoid::Document

  before_save :encrypt_password

  validates :username, presence: true

  attr_accessor :password

  field :first_name, type: String
  field :last_name, type: String
  field :username, type: String
  field :encrypted_password, type: String
  field :phone, type: String
  field :email
  field :address, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :credit_card, type: String
  field :cvv, type: String
  field :exeration_date, type: String

  has_many :tickets

  def self.authenticate(username, password)
    begin
      user = User.where(username: username).first
      return user && user.encrypted_password == password.crypt("$5$round=7845$salt$")
    rescue Mongo::Error::NoServerAvailable

    end
  end

  def self.validate_username(username)
    begin
    user = User.where(username: username).first
    return !user
    rescue Mongo::Error::NoServerAvailable, SocketError
      return true
    end
  end

  def encrypt_password
    if password
      self.encrypted_password = password.crypt("$5$round=7845$salt$")
    end
  end


end