require "parser"

describe Parser do
  describe "Initialize class" do
    it "raises if no path to log file given" do
      expect { Parser.new }.to raise_exception(ArgumentError)
    end

    it "raises if path to given to non-existent log file" do
      allow(File).to receive(:exists?).and_return(false)
      expect { Parser.new(log_file: "/some/path") }.to raise_exception("Invalid log file")
    end

    it "raises if log file empty" do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:size).and_return(0)
      expect { Parser.new(log_file: "/some/path") }.to raise_exception("Invalid log file")
    end

    it "should not raise with path to valid log file" do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:size).and_return(1)
      expect { Parser.new(log_file: "/some/path") }.to_not raise_exception
    end

    it "sets instance variables to zero/empty" do
      allow(File).to receive(:exists?).and_return(true)
      allow(File).to receive(:size).and_return(1)
      parser = Parser.new(log_file: "/some/path")
      expect(parser.valid_lines).to be_empty
      expect(parser.line_count).to be(0)
    end
  end

  describe "Methods" do
    let(:parser) { Parser.new(log_file: "/some/path") }
    let(:log_file) { "some junk text\n/a/b 1.2.3.4\n/c/d 5.6.7.8\n/a/b 1.2.3.4" }

    describe "#parse" do
      it "should only parse valid lines" do
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:size).and_return(1)
        allow(File).to receive(:read).and_return(log_file)

        parser.parse

        expect(parser.line_count).to eq(4)
        expect(parser.valid_lines.count).to eq(3)
      end
    end

    describe "#lines_grouped_by_uri_path" do
      it "should group all the lines by uri" do
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:size).and_return(1)
        allow(File).to receive(:read).and_return(log_file)

        parser.parse
        lines_grouped_by_uri_path = parser.send(:lines_grouped_by_uri_path)

        expect(lines_grouped_by_uri_path).to include("/a/b", "/c/d")
      end
    end

    describe "#order_uris_by_visits" do
      it "should build array of results by visits" do
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:size).and_return(1)
        allow(File).to receive(:read).and_return(log_file)

        parser.parse
        order_uris_by_visits = parser.order_uris_by_visits

        expect(order_uris_by_visits).to eq([
	  Parser::Result.new("/a/b", 2),
	  Parser::Result.new("/c/d", 1)
	])
      end
    end

    describe "#order_urls_by_unique_visits" do
      it "should build aray of results by unique visits" do
        allow(File).to receive(:exists?).and_return(true)
        allow(File).to receive(:size).and_return(1)
        allow(File).to receive(:read).and_return(log_file)

        parser.parse
        order_uris_by_unique_visits = parser.order_uris_by_unique_visits

        expect(order_uris_by_unique_visits).to eq([
	  Parser::Result.new("/a/b", 1),
	  Parser::Result.new("/c/d", 1)
	])
      end
    end
  end
end
