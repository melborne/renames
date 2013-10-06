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

  describe '.renames' do
    it "renames multiple files at once" do
      from = %w(a.txt b.txt c.txt)
      to   = %w(x.txt y.txt z.txt)
      from.each { |f| File.write(f, '') }
      Renames.renames(from, to)
      expect(to.all? { |t| File.exist? t }).to be_true
    end

    it 'swaps file names' do
      from, to = %w(a.txt b.txt), %w(b.txt a.txt)
      from.each { |f| File.write(f, '') }
      Renames.renames(from, to)
      expect(to.all? { |t| File.exist? t }).to be_true
    end
  end
end

