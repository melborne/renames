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

    it 'raise an error when the target name exist in the target directory' do
      from, to = 'abc.txt', 'xyz.txt'
      File.write(from, '')
      File.write(to, '')
      expect{ Renames.rename(from, to) }.to raise_error(ArgumentError)
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

    it 'raises error when size of from differ from tos' do
      from, to = %w(a.txt b.txt), %w(c.txt)
      from.each { |f| File.write(f, '') }
      expect{ Renames.renames(from, to) }.to raise_error(ArgumentError)
    end

    it 'raise an error before renaming any of files when a file exist' do
      from = %w(a.txt b.txt c.txt)
      to   = %w(x.txt y.txt z.txt)
      from.each { |f| File.write(f, '') }
      File.write('y.txt', '')
      msg = 'Any of the target files are already exist.'
      expect { Renames.renames(from, to) }.to raise_error(ArgumentError, msg)
    end

    it 'raise an error when symbolic files are included' do
      from, to = %w(a.txt b.txt), %w(x.txt y.txt)
      File.write(from[0], '')
      File.symlink(from[0], from[1])
      expect { Renames.renames(from, to) }.to raise_error(ArgumentError)
    end

    it 'raise an error when non-writable files are included' do
      pending "FakeFs's writable check is not work correctly."
      from, to = %w(a.txt b.txt), %w(x.txt y.txt)
      from.each { |f| File.write f, '' }
      FileUtils.chmod(0555, 'b.txt')
      expect{ Renames.renames(from, to) }.to raise_error(ArgumentError)
    end
  end
end

