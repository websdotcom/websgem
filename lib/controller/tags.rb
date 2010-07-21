module Webs
  module Controller
    module Tags
      def fwml tagname, options={}, &block
        s_options = options.each_key.collect{|k| "#{k.to_s}=\"#{options[k]}\"" }.join(' ')
        return "<fw:#{tagname} #{s_options} />" unless block
        concat("<fw:#{tagname} #{s_options} >")
        yield
        concat("</fw:#{tagname}>")
      end  
    end
  end
end