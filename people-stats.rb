$:.unshift 'lib'

require 'json'
require 'core_ext'

TOPIC = '2009-09-21__07-22-57__mama1ari'

demographics = JSON.parse(File.read("topics/#{TOPIC}.txt"))

File.write 'demographics.csv', demographics['comments'].map{|c|
    [c['from']['id'],
        c['body']]
}.select{|author, text| text =~ /\d{2,4}/}.reject{|a, t| t.include?('#')}.
map{|author, text| 
    [author, text.sub(/^\D+/, '').sub(/^(\d{2})(\D)/, '19\1\2').gsub(',', ';').sub(/(\d)(\D)/, '\1,\2').gsub(',;', ',')]
}.sort.map{|ln| ln.join(', ')}.join("\n")