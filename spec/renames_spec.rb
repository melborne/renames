require 'spec_helper'
require 'fakefs/spec_helpers'

describe Renames do
  include FakeFS::SpecHelpers
  it 'should have a version number' do
    Renames::VERSION.should_not be_nil
  end

  describe '.rename' do
    it "renames 'a' to 'b'" do
      from, to = 'abc.txt', 'xyz.txt'
      File.write(from, '')
      Renames.rename(from, to)
      expect(File.exist? to).to be_true
    end
  end
end

