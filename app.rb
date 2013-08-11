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

#
# Web interface
#
get '/' do
  @listing = Participant.order(:name).all
  erb :"listing"
end

get '/participant/:hash/report' do
  @p = Participant.find_by_namehash(params[:hash])
  erb :"participant/report"
end

#
# JSON API
#
get '/api/participants.json' do
  content_type :json
  Participant.all.to_json
end

get '/api/participant/:hash/votes.json' do
  content_type :json
  p = Participant.find_by_namehash(params[:hash])
  p.votes.to_json
end

get '/update' do
  scraping_time = Time.now

  base_url  = "http://elcorteingles.glamour.es/street-fashion-show/ranking/"

  # Get number of pages
  url = base_url + "1"
  doc = Nokogiri::HTML(open(url))
  num_pages = doc.css(".interval-last").text.to_i

  data = Hash.new

  for page in 1..num_pages
    puts page
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

    if p.votes.count == 0 or values[:votes].to_i > p.votes.last.number
      v = Vote.create(participant: p,
        number: values[:votes],
        created_at: scraping_time)
    end
  end

"Updated"

end
