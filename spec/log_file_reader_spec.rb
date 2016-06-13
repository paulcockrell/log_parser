require "log_parser/log_file_reader"

describe LogParser::LogFileReader do
  let(:log_files) { ["/some/path/1", "/some/path/2"] }
  let(:regex) { /^(\/[a-z0-9\-_\/]*)\s((?:\d{1,3}\.){3}\d{1,3})/ }
  let(:log_file_reader) { LogParser::LogFileReader.new(log_files: log_files, line_regex: regex) }
  let(:log_file) { "some junk text\n/path/1 1.2.3.4\n/path/1 1.2.3.5\n/path/2 5.6.7.8" }

  describe "Initialize class" do
    it "raises if instanciated without arguments" do
      expect { LogParser::LogFileReader.new }.to raise_exception(ArgumentError)
    end

    it "rejects log files if they don't exist" do
      allow(File).to receive(:exists?).and_return(false)

      expect(log_file_reader.invalid_log_files).to eq(log_files)
    end

    it "rejects log files if they don't contain any lines of data" do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:size).and_return(0)

      expect(log_file_reader.invalid_log_files).to eq(log_files)
    end

    it "should accept multiple valid log files" do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:size).and_return(1)

      expect(log_file_reader.valid_log_files).to eq(log_files)
    end

    it "should set counters to zero" do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:size).and_return(1)

      expect(log_file_reader.line_count).to be(0)
    end

  end

  describe "Methods" do
    describe "#readings" do
      it "should only parse valid lines" do
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:size).and_return(1)
	allow(File).to receive(:read).and_return(log_file)

        expect(log_file_reader.readings.count).to eq(6)
        expect(log_file_reader.line_count).to eq(8)
      end
    end
  end
end

describe LogParser::LogFileReader::Reading do
  let(:uri_path)   { "/path/1" }
  let(:ip_address) { "1.2.3.4" }
  let(:reading)    { LogParser::LogFileReader::Reading.new(uri_path: uri_path, ip_address: ip_address) }

  describe "Public attributes" do
    it "should initialize values and give read only access to uri_path and ip_address" do
      expect(reading.uri_path).to eq(uri_path)
      expect(reading.ip_address).to eq(ip_address)
      expect{reading.uri_path = uri_path}.to raise_exception(NoMethodError)
      expect{reading.ip_address = ip_address}.to raise_exception(NoMethodError)
    end
  end
end
