require 'httparty'
require 'sinatra'
require 'send_file'

get "/" do
	erb :index
end

get "/config" do
	response = HTTParty.get("http://dockvpn_serveconfig_1:8080")
    tempfile = Tempfile.new('client.ovpn')
    File.open(tempfile.path,'w') do |f|
       f.write response.body
    end
	send_file(tempfile)
end
