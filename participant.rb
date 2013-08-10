require 'sinatra/activerecord'

class Participant < ActiveRecord::Base
  validates_presence_of :name, :namehash

  has_many :votes

  def serializable_hash(options = nil)
    { :name => name, :hash => namehash}
  end
end