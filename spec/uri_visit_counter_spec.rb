require "log_parser/log_file_reader"
require "log_parser/uri_visit_counter"

describe LogParser::UriVisitCounter do
  let(:log_files)         { ["/some/path/1", "/some/path/2"] }
  let(:regex)             { /^(\/[a-z0-9\-_\/]*)\s((?:\d{1,3}\.){3}\d{1,3})/ }
  let(:log_file_reader)   { LogParser::LogFileReader.new(log_files: log_files, line_regex: regex) }
  let(:uri_visit_counter) { LogParser::UriVisitCounter.new log_file_reader.readings }
  let(:log_file)          { "some junk text\n/path/1 1.2.3.4\n/path/1 1.2.3.5\n/path/2 5.6.7.8" }

  describe "Methods" do
    before do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:size).and_return(1)
      allow(File).to receive(:read).and_return(log_file)
    end

    describe "#uris_by_visits" do
      it "should return array of results ordered by total visits" do
        uris_by_visits = uri_visit_counter.uris_by_visits

        expect(uris_by_visits[0].uri_path).to eq("/path/1")
        expect(uris_by_visits[0].visit_count).to eq(4)
        expect(uris_by_visits[1].uri_path).to eq("/path/2")
        expect(uris_by_visits[1].visit_count).to eq(2)
      end
    end

    describe "#uris_by_unique_visits" do
      it "should return array of results ordered by unique visits" do
        uris_by_unique_visits = uri_visit_counter.uris_by_unique_visits

        expect(uris_by_unique_visits[0].uri_path).to eq("/path/1")
        expect(uris_by_unique_visits[0].unique_visit_count).to eq(2)
        expect(uris_by_unique_visits[1].uri_path).to eq("/path/2")
        expect(uris_by_unique_visits[1].unique_visit_count).to eq(1)
      end
    end
  end
end

describe LogParser::UriVisitCounter::UriVisit do
  let(:uri_path_1)   { "/path/1" }
  let(:uri_path_2)   { "/path/2" }
  let(:ip_address_1) { "1.2.3.4" }
  let(:ip_address_2) { "5.6.7.8" }
  let(:uri_visit_1)  { LogParser::UriVisitCounter::UriVisit.new(uri_path: uri_path_1) }
  let(:uri_visit_2)  { LogParser::UriVisitCounter::UriVisit.new(uri_path: uri_path_2) }
  let(:reading_1)    { LogParser::LogFileReader::Reading.new(uri_path: uri_path_1, ip_address: ip_address_1) }
  let(:reading_2)    { LogParser::LogFileReader::Reading.new(uri_path: uri_path_2, ip_address: ip_address_2) }

  describe "Public attributes" do
    it "should initialize values and give read only access to uri_path" do
      expect(uri_visit_1.uri_path).to eq(uri_path_1)
    end
  end

  describe "Methods" do
    describe "#add" do
      it "should add valid readings (same uri path to one initialized with)" do
        10.times { uri_visit_1.add reading_1 }
        expect(uri_visit_1.uri_path).to eq(uri_path_1)
        expect(uri_visit_1.visits.count).to eq(10)
      end

      it "should reject invalid readings (different uri path to one initialized with)" do
        10.times { uri_visit_1.add reading_1 }
        10.times { uri_visit_1.add reading_2 }
        expect(uri_visit_1.uri_path).to eq(uri_path_1)
        expect(uri_visit_1.visits.count).to eq(10)
      end
    end

    describe "#<=>" do
      it "should be comparable with itself sorting by visit count value" do
        10.times { uri_visit_1.add reading_1 }
	20.times { uri_visit_2.add reading_2 }
	expect([uri_visit_2, uri_visit_1].sort).to eq([uri_visit_1, uri_visit_2])
      end
    end

    describe "#visits_count" do
      it "should return all visits as a value" do
	10.times { uri_visit_1.add reading_1 }
        expect(uri_visit_1.visit_count).to eq(10)
      end
    end

    describe "#unique_visits_count" do
      it "should return all unique visits as a value" do
	10.times { uri_visit_1.add reading_1 }
        expect(uri_visit_1.unique_visit_count).to eq(1)
      end
    end
  end
end
