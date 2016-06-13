module LogParser
  class LogFileReader
    attr_reader :line_count, :valid_readings
  
    def initialize(log_files:, line_regex:)
      @log_files = log_files.uniq
      @line_regex = Regexp.new line_regex
      @line_count = 0
    end
  
    def readings
      return @_readings if @_readings

      @_readings = []

      valid_log_files.each do |log_file|
          File.read(log_file).each_line.map do |raw_line|
            @line_count += 1
            parse_line(raw_line) do |reading|
              @_readings << reading
            end
          end
      end
  
      @_readings
    end
  
    def valid_log_files
      @_valid_log_files ||= @log_files.select {|lf| File.exists?(lf) && File.size(lf) >= 1}
    end 

    def invalid_log_files
      @log_files - valid_log_files
    end
  
    private
  
    def parse_line(line)
      if match = line.match(@line_regex)
        yield Reading.new(uri_path: match[1], ip_address: match[2])
      end
    end

    class Reading
      attr_reader :uri_path, :ip_address
    
      def initialize(uri_path:, ip_address:)
        @uri_path = uri_path
        @ip_address = ip_address
      end
    end
  end
end
