require 'sinatra'
require 'rubygems'
require 'nokogiri'
require 'sinatra/activerecord'
require 'open-uri'
require 'digest/md5'

require "./participant"
require './vote'

configure :development, :test do
  set :database, 'sqlite:///db.sqlite3'
end
configure :production do
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
end

get '/api/participants.json' do
  Participant.all.to_json
end

get '/api/participant/:hash/votes.json' do
  p = Participant.find_by_namehash(params[:hash])
  p.votes.to_json
end

get '/update' do
  base_url  = "http://elcorteingles.glamour.es/street-fashion-show/ranking/"

  data = Hash.new

  for page in 1..21
    url = base_url + page.to_s
    # Fetch page
    doc = Nokogiri::HTML(open(url))
    doc.css(".list li").each do |item|
    # Get data
    p_hash = Digest::MD5.hexdigest(item.at_css("a").text)
    p_name = item.at_css("a").text
    p_votes = item.at_css(".votes").text

    # Temporaly store it
    data[p_hash] = {
      :name => p_name,
      :votes => p_votes
    }
    end
  end

  data.each do |key, values|
    p = Participant.find_or_create_by(
      name: values[:name],
      namehash: key)
    v = Vote.create(participant: p,
      number: values[:votes],
      created_at: Time.now)
  end

"Updated"

end
