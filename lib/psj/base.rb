#require File.dirname(__FILE__)+"/psobject.rb"
module PS
  class Base 
    extend Util
    #hmm...
    extend Api
    include Api
    ## params.keys = {
    # :host,
    # :apikey
    # :userkey
    # :company_name
    #}

    def self.establish_connection(params={})
      connect(params.delete(:format))
      params[:env] ||= "development"
      validate_and_assign(params)
    end

    def current_connection
      config = {
        :apikey => $api.apikey,
        :userkey => $api.userkey,
        :host => host()
      }
      p config
    end

    private
      def self.validate_and_assign(params)
        required_attributes().each do |key|
          if params.key?(key) then
            $api.send(key.to_s+"=", params[key])
          else
            raise "Missing required attribute: #{key}"
          end
        end
      end
  end
end
