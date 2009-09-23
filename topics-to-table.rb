$:.unshift 'lib', 'ext'

require 'pp'
require 'time'


require 'core_ext'
require 'json'

data = Dir['topics/*.txt'].map{|file|
    begin
        JSON.parse(File.read(file).gsub("\n", ' '))
    rescue
        puts file
        raise
    end
}.map{|entry|
    
    entry.merge(
        'tags' => (entry['body'] + ' ' + (entry['comments'] || []).
            map{|c| c['body']}.join(' ')).
            scan(/\#(?:[-a-zA-Z0-9_]+)/).
            reject{|t| t == '#ay4_2read'}.
            sort.
            join('; '),
        'name' => entry['url'].sub('http://friendfeed.com/culturecodes/', '')
    )
}

byposts = data.map{|entry|
    [entry['from']['id'], 
        'author',
        entry['name'],
        entry['tags'],
        entry['url']]
}

bylikes = data.map{|entry|
    (entry['likes'] || []).map{|l| 
        [l['from']['id'],
        'like',
        entry['name'],
        entry['tags'],
        entry['url']]
    }
}.flatten(1)

result = (byposts + bylikes).sort.map{|ln| ln.join(', ')}.join("\n")


File.write 'stats2.csv', result