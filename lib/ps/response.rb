module PS 
  class Response < Base
    attr_accessor :is_success,:error_message,:sub_type,:ps_object,:total_items,:items_per_page,:current_page,:error_type

    #### Some Basic fields returned by Paysimple
    # {
    ## 'd' => {
    ### '__type' => String,
    ### 'CurrentPage => Int,
    ### 'ErrorMessage => String
    ### 'ErrorType' => Int,
    ### 'IsSuccess' => boolean,
    ### 'itemsPerPage' => Int,
    ### 'PsObject' => {
    #### ...
    ### },
    ### 'SubType' => String, <-- This tells us the subclass of PsObject
    ### 'TotalItems' => Int
    ## }
    # }
    def initialize(params={})
      params.each { |k,v| instance_variable_set("@#{k.snake_case}", v) }
      successful?
      prepare_ps_object() if @ps_object
      self
    end

    private 
      def successful?
        raise RequestError, @error_message unless @is_success == true
      end

      def prepare_ps_object
        prepare_dates()
        snake_case_response()
        @ps_object = Util.convert_to_ps_object(self) 
      end
      
      #Paysimple returns the attribute names in CamelCase, but the attributes use
      #snake_case within the code base. The method bellow converts the attribute 
      #names into snake_case so that they can be more easily dynamically assigned
      #to the appropriate class.
      def snake_case_response
        @ps_object = @ps_object.map { |ps_object| ps_object.snake_case_keys }
      end

      def prepare_dates
        @ps_object.each_with_index do |object, i|
          object.each do |key, value|
            if date?(value) then
              @ps_object[i][key] = parse_date(value)
            end
          end
        end
      end
  end
end
