class Parser
  attr_reader :log_file, :line_count, :valid_lines

  Line = Struct.new(:uri_path, :ip_address)
  Result = Struct.new(:uri_path, :count)
  LINE_REGEX = /^(\/[a-z0-9\-_\/]*)\s((?:\d{1,3}\.){3}\d{1,3})/

  def initialize(log_file:)
    raise "Invalid log file" unless valid_log_file? log_file

    @log_file = log_file
    @line_count = 0
    @valid_lines = []
  end

  def parse
    with_each_valid_line do |line|
      valid_lines << create_line(line)
    end
  end

  def order_uris_by_visits
    return @order_uris_by_visits if @order_uris_by_visits

    @order_uris_by_visits = lines_grouped_by_uri_path
    .map do |uri_path, entries| 
      Result.new(uri_path, entries.count)
    end
    .sort do |result_a, result_b|
      result_b.count <=> result_a.count
    end
  end

  def order_uris_by_unique_visits
    return @order_uris_by_unique_visits if @order_uris_by_unique_visits

    @order_uris_by_unique_visits = lines_grouped_by_uri_path
    .map do |uri_path, entries| 
      count = entries
      .map(&:ip_address)
      .uniq
      .count

      Result.new(uri_path, count)
    end
    .sort do |result_a, result_b| 
      result_b.count <=> result_a.count
    end
  end


  private

  def with_each_valid_line
    File.read(@log_file).each_line do |line|
      @line_count += 1

      if valid_line? line
        yield line
      end
    end
  end

  def create_line(line)
    uri_path, ip_address = line.split(/ /)
    Line.new(uri_path.chomp, ip_address.chomp)
  end

  def valid_line?(line)
    line =~ LINE_REGEX
  end

  def valid_log_file?(log_file)
    File.exists?(log_file) && File.size(log_file) > 0 ? true : false
  end

  def lines_grouped_by_uri_path
    return @lines_grouped_by_uri_path if @lines_grouped_by_uri_path
    
    @lines_grouped_by_uri_path = valid_lines.group_by do |line| 
      line.uri_path
    end
  end
end
