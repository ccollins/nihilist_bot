require 'bot_parser_format'

class BotParser
  @formats = []
  
  class << self
    attr_reader :formats
    
    def register_format(format_name, format, &block)
      formats << BotParserFormat.new(format_name, format, &block)
    end
  end
  
  def formats()  self.class.formats;  end
  
  register_format :image, /^\s*(http:\S+\.(?:jpe?g|png|gif))(?:\s+(\S.*))?$/i do |md, _|
    { :source => md[1], :caption => md[2] }
  end
  
  register_format :video, %r{^\s*(http://(?:www\.)?youtube\.com/\S+\?\S+)(?:\s+(.*))?$}i do |md, _|
    { :embed => md[1], :caption => md[2] }
  end
  
  register_format :quote, /^\s*"([^"]+)"\s+--\s*(.*)\s+\((https?:.*)\)$/i do |md, _|
    { :quote => md[1], :source => md[2], :url => md[3] }
  end
  
  register_format :quote, /^\s*"([^"]+)"\s+--\s*(.*)$/ii do |md, _|
    { :quote => md[1], :source => md[2] }
  end
  
  register_format :link, %r{^\s*(?:(.*?)\s+)?(https?://\S+)\s*(?:\s+(\S.*))?$}i do |md, _|
      title = md[1] || Kernel::BotHelper.get_link_title(md[2])
      { :url => md[2], :name => title, :description => md[3] }
  end
  
  register_format :fact, %r{^\s*fact:\s+(.*)}i do |md, _|
    { :title => "FACT: #{md[1]}" }
  end
  
  register_format :true_or_false, %r{^\s*(?:(?:true\s+or\s+false)|(?:t\s+or\s+f))\s*[:\?]\s+(.*)}i do |md, _|
    { :title => "True or False?  #{md[1]}" }
  end
  
  def parse(sender, channel, mesg)
    return nil if mesg.empty?
    
    common = { :poster => sender, :channel => channel }
    
    # This is bunk, but I'm tired and can't think of the right way to do this
    # I was trying formats.detect, but that just returns the format, not the result
    result = nil
    formats.each do |f|
      result = f.process(mesg)
      break if result
    end
    
    return nil unless result
    
    Kernel::BotHelper.add_poster_info(common.merge(result))
  end
end
