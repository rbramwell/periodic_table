require 'savon'

module PeriodicTable
  class PeriodicTableApi
    def initialize
      @client = Savon.client do
        wsdl 'http://www.webservicex.net/periodictable.asmx?WSDL'
      end
    end

    def query(element_name)
      api_response = @client.call :get_atomic_number, :message => {'ElementName' => element_name}
      result = api_response.to_hash[:get_atomic_number_response][:get_atomic_number_result]
      ApiResponse.new(result)
    end
  end

  class ApiResponse
    def initialize(result)
      xml = Nokogiri::XML.parse(result)
      @data = xml.xpath("NewDataSet/Table").first.element_children
    end

    def method_missing(method)
      method = method.to_s
      # the webservicex api mispells "electronegativity"
      method = 'eletronegativity' if method == 'electronegativity'
      element = @data.find { |e| e.name =~ /#{method.gsub('_', '')}/i }
      element.text if element
    end
  end
end
