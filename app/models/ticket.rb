class Ticket
  include Mongoid::Document

  field :origin
  field :destination
  field :train
  field :price
  field :first_class
  field :time
  belongs_to :user
end