require File.dirname(__FILE__) + '/spec_helper'

describe "IniParse::LineTypes::Line" do
  Line = IniParse::LineTypes::Line

  describe '#sanitize_line' do
    def sanitize_line(line)
      Line.sanitize_line(line)
    end

    it 'should not change the original string' do
      orig = ' my line = value ; with comment '
      lambda { sanitize_line(orig) }.should_not change(orig, :length)
    end

    it 'should not change the default options' do
      lambda { sanitize_line(' m=y ; comment') }.should_not \
        change(IniParse::LineTypes::Line, :default_opts)
    end

    describe 'with "k = v"' do
      it 'should set no comment, offset or separator' do
        opts = sanitize_line('k = v')[1]
        opts[:comment].should        == Line.default_opts[:comment]
        opts[:comment_offset].should == Line.default_opts[:comment_offset]
        opts[:comment_sep].should    == Line.default_opts[:comment_sep]
      end

      it 'should leave the line intact' do
        sanitize_line('k = v')[0].should == 'k = v'
      end
    end

    describe 'with "k = v  \t "' do
      it 'should strip trailing whitespace from the line' do
        sanitize_line("k = v  \t  ")[0].should == 'k = v'
      end
    end

    describe 'with "k = a value with spaces"' do
      it 'should set the line correctly' do
        sanitize_line('k = a value with spaces')[0].should == 'k = a value with spaces'
      end
    end

    describe 'with " k = v ; a comment "' do
      before(:all) { @line = ' k = v ; a comment ' }

      it 'should return the line stripped of whitespace and comments' do
        sanitize_line(@line)[0].should == 'k = v'
      end

      it 'should strip leading whitespace from the line and set the indent option' do
        line, opts = sanitize_line(@line)
        line.should == 'k = v'
        opts[:indent].should == ' '
      end

      it 'should set opts[:comment] to "a comment"' do
        sanitize_line(@line)[1][:comment].should == 'a comment'
      end

      it 'should set opts[:comment_offset] correctly' do
        sanitize_line(@line)[1][:comment_offset].should == 7
      end

      it 'should set opts[:comment_sep] correctly' do
        sanitize_line(@line)[1][:comment_sep].should == ';'
        sanitize_line('k = v # a comment')[1][:comment_sep].should == '#'
      end
    end

    describe 'with "k = v;w;x y;z"' do
      before(:all) { @line = 'k = v;w;x y;z' }

      it 'should set the line correctly' do
        sanitize_line(@line)[0].should == 'k = v;w;x y;z'
      end

      it 'should not set a comment' do
        opts = sanitize_line(@line)[1]
        opts[:comment].should        == Line.default_opts[:comment]
        opts[:comment_offset].should == Line.default_opts[:comment_offset]
        opts[:comment_sep].should    == Line.default_opts[:comment_sep]
      end
    end

    describe 'with "k = v;w ; a comment"' do
      before(:all) { @line = 'k = v;w ; a comment' }

      it 'should return the line as "k = v;w' do
        sanitize_line(@line)[0].should == 'k = v;w'
      end

      it 'should set opts[:comment] to "a comment"' do
        sanitize_line(@line)[1][:comment].should == 'a comment'
      end

      it 'should set opts[:comment_offset] correctly' do
        sanitize_line(@line)[1][:comment_offset].should == 8
      end
    end
  end
end