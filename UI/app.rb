require 'httparty'
require 'sinatra'
require 'send_file'

get "/" do
	IP = HTTParty.get("http://ipv4.icanhazip.com")
	body "<h2>Single Use Download</h2><p>All subsequent requests will fail, and a new VPN server will need to be provisioned in order to regenerate.</p><a href='/config' download='client.ovpn'>Download Config</a>"
end

get "/config" do   
	response = HTTParty.get("http://dockvpn_serveconfig_1:8080")
    tempfile = Tempfile.new('client.ovpn')
    File.open(tempfile.path,'w') do |f|
       f.write response.body
    end
	send_file(tempfile)
    Process.kill('KILL', Process.pid)
end
