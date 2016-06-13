module LogParser
  class UriVisitCounter
    def initialize(readings = nil)
      @visit_counter = {}
      readings.each {|reading| add reading} if readings
    end
  
    def add(reading)
      unless @visit_counter.has_key? reading.uri_path 
        @visit_counter[reading.uri_path] = UriVisit.new(uri_path: reading.uri_path)
      end
  
      @visit_counter[reading.uri_path].add reading
    end
  
    def uris_by_visits
      @visit_counter.values.sort.reverse
    end
  
    def uris_by_unique_visits
      @visit_counter.values.sort_by(&:unique_visit_count).reverse
    end
  
    private
  
    class UriVisit
      include Comparable
      attr_reader :visits, :uri_path
  
      def initialize(uri_path:)
        @visits = []
        @uri_path = uri_path
      end
  
      def add(reading)
        if valid? reading.uri_path
          @visits << reading.ip_address
        else
          nil
        end
      end
  
      def <=>(other)
        visit_count <=> other.visit_count
      end
  
      def visit_count
        visits.count
      end
  
      def unique_visit_count
        visits.uniq.count
      end
  
  
      private
  
      def valid?(uri_path)
        @uri_path == uri_path
      end
    end
  end
end
