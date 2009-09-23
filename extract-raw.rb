$:.unshift 'lib'

require 'pp'
require 'time'

require 'core_ext'
require 'json'
require 'open-uri'

def parse_date(str)
    str =~ /(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)Z/
    Time.local($1, $2, $3, $4, $5, $6)
end

class String
    def to_json
        '"' + self.gsub('\\', '\\\\\\').gsub('"', '\"') + '"'
    end
end

class FriendFeed
    def feed(name, params)
        request("feed/#{name}", params)
    end

    def request(method, params = {})
        url = construct_url(method, params)
        response_str = open(url).read
        response = JSON.parse(response_str)
        response['errorCode'] && raise(RuntimeError, response['errorCode']) 
        response
    end

    def construct_url(method, params)
        "http://friendfeed-api.com/v2/#{method}?" + params.map{|k, v| "#{k}=#{v}"}.join('&')
    end
end

def feed_grab_split
    frf = FriendFeed.new
    s = 0
    while true
        data = frf.feed('culturecodes', :start => s, :num => 100)
        break if data['entries'].empty?
        data['entries'].each do |e|
            name = "topics/" + parse_date(e['date']).strftime('%Y-%m-%d__%H-%M-%S') + "__#{e['from']['id']}.txt"
            File.write(name, e.to_json)
        end
        s += 100
    end
end

feed_grab_split

#puts 'test \\'.to_json