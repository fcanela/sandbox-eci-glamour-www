require 'sinatra/activerecord'

class Vote < ActiveRecord::Base
  validates_presence_of :participant, :number, :created_at

  belongs_to :participant


  def serializable_hash(options = nil)
    { :date=> created_at, :votes => number }
  end
end