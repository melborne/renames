require "renames/version"
require 'renames/core_ext'
require 'tmpdir'
require 'fileutils'

using CoreExtention

class Renames
  class << self
    def rename(from, to)
      validate_file_existence(to)
      ::File.rename(from, to) unless from == to
    end

    def renames(froms, tos)
      froms, tos = [froms, tos].map { |f| f.to_enum }
      validate_files(froms, tos)
      Dir.mktmpdir do |dir|
        tmp_froms = froms.lazy.map { |f| ::File.join(dir, f) }
        loop { FileUtils.copy_file(froms.next, tmp_froms.next, true) }
        [froms, tmp_froms].map(&:rewind)
        loop { FileUtils.rm(froms.next) }
        loop { rename(tmp_froms.next, tos.next) }
      end
      puts "finished: #{froms.to_a.size} files renamed."
    end

    private
    def validate_files(froms, tos)
      validate_num_of_files(froms, tos)
    end

    def validate_num_of_files(froms, tos)
      unless [froms, tos].same? { |l| l.to_a.size }
        raise ArgumentError, "Numbers of files must match 'from' and 'to'."
      end
      true
    end

    def validate_file_existence(file)
      if ::File.exist?(file)
        raise ArgumentError, "File already exist: #{file}."
      end
    end
  end
end
