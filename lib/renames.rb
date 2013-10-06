require "renames/version"
require 'tmpdir'
require 'fileutils'

class Renames
  class << self
    def rename(from, to)
      ::File.rename(from, to) unless from == to
    end

    def renames(froms, tos)
      froms, tos = [froms, tos].map { |f| f.to_enum }
      Dir.mktmpdir do |dir|
        tmp_froms = froms.lazy.map { |f| ::File.join(dir, f) }
        loop { FileUtils.copy_file(froms.next, tmp_froms.next, true) }
        [froms, tmp_froms].map(&:rewind)
        loop { FileUtils.rm(froms.next) }
        loop { rename(tmp_froms.next, tos.next) }
      end
      puts "finished: #{froms.to_a.size} files renamed."
    end
  end
end
