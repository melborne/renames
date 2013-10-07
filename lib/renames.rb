require "renames/version"
require 'renames/core_ext'
require 'tmpdir'
require 'fileutils'

using CoreExtention

class Renames
  class << self
    def rename(from, to)
      validate_file_existence(to, [from])
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

    def renames_in_sequence(froms)
      tos = build_sequencial_names(froms.first)
      renames(froms, tos)
    end

    private
    def validate_files(froms, tos)
      msg = 'Any of the target files are already exist.'
      exclude = froms.to_a
      files = tos.take(froms.to_a.size).to_enum
      loop { |t| validate_file_existence(files.next, exclude, msg) }
      validate_bad_filetype(froms)
    ensure
      tos.rewind
    end

    def validate_file_existence(file, exclude, msg="File already exist: #{file}.")
      if ::File.exist?(file) && !exclude.include?(file)
        raise ArgumentError, msg
      end
      true
    end

    def validate_bad_filetype(files)
      bad_files =
        files.select do |f|
          fs = ::File.lstat(f)
          !fs.writable? || (fs.nlink > 1) || fs.symlink?
        end
      unless bad_files.empty?
        raise ArgumentError, "Non-writable or link files included: #{bad_files.join(', ')}"
      end
      true
    end

    def build_sequencial_names(top)
      Enumerator.new do |y|
        base, ext = split_filename(top)
        loop { y << [base, ext].join; base = base.next }
      end
    end

    # split to 'dir+base' and 'ext'
    # ex. 'a.tar.gz' => ['a', '.tar.gz']
    #     'b' => ['b', nil]
    def split_filename(file)
      file.match(/(.*?)(\..+)*$/) { [$1, $2] }
    end
  end
end
