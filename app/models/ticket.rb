class Ticket
  include Mongoid::Document

  field :origin, type: String
  field :destination, type: String
  field :train, type: String
  field :price, type: String
  field :first_class, type: Boolean
  field :time, type: String
  field :quantity, type: Integer
  belongs_to :user
end