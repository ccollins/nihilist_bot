require 'open-uri'

class BotFilter::LinkTitle < BotFilter
  def process(data)
    raise TypeError unless data.is_a?(Hash)
    
    title = data[:name]
    unless title
      begin
        open(data[:url]) do |f|
          title = f.read.match(/<title>(.*)<\/title>/)[1]
        end
      rescue
        title = ''
      end
    end
    
    result = data
    result[:name] = title
    result
  end
end