require "files/version"


module Files
  def self.create options = {:remove => true}, &block
    require 'tmpdir'
    require 'fileutils'

    called_from = File.basename caller.first.split(':').first, ".rb"
    path = File.join(Dir::tmpdir, "#{called_from}_#{Time.now.to_i}_#{rand(1000)}")

    files = Files.new path, block, options

    files.root
  end
  
  class Files
    
    attr_reader :root
    
    def initialize path, block, options
      @root = path
      @dirs = [path]

      Dir.mkdir(path)
      at_exit {FileUtils.rm_rf(path) if File.exists?(path)} if options[:remove]

      instance_eval &block
    end

    def dir name, &block
      Dir.mkdir "#{current}/#{name}"
      @dirs << name
      instance_eval &block
    end
    
    def file name, contents = "contents of #{name}"
      if name.is_a? File
        FileUtils.cp name.path, current
      else
        path = "#{current}/#{name}"
        if contents.is_a? File
          FileUtils.cp contents.path, path
        else
          File.open(path, "w") do |f|
            f.write contents
          end
        end
      end
    end
    
    private
    def current
      @dirs.join('/')
    end
    
  end
end

def Files *args, &block
  Files.create *args, &block
end
