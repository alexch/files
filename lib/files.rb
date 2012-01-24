require "files/version"

module Files

  # class methods
  
  def self.default_options level = 2
    {:remove => true, :name => called_from(level)}
  end
  
  def self.called_from level = 1
    File.basename caller[level].split(':').first, ".rb"
  end
  
  def self.create options = default_options, &block
    require 'tmpdir'
    require 'fileutils'

    name = options[:name]
    path = File.join(Dir::tmpdir, "#{name}_#{Time.now.to_i}_#{rand(1000)}")

    Files.new path, block, options
  end
  
  # mixin methods
  def files options = ::Files.default_options   # todo: block
    @files ||= ::Files.create(options)
  end
  
  def file *args, &block
    files.file *args, &block
  end
  
  def dir *args, &block
    files.dir *args, &block
  end
  
  # concrete class for creating files and dirs under a temporary directory  
  class Files
    
    attr_reader :root
    
    def initialize path, block, options
      @root = path
      @dirs = []
      dir path, &block
      @dirs = [path]
      at_exit {remove} if options[:remove]
    end

    def dir name, &block
      path = "#{current}/#{name}"
      Dir.mkdir path
      @dirs << name
      Dir.chdir(path) do
        instance_eval &block if block
      end
      @dirs.pop
      path
    end
    
    def file name, contents = "contents of #{name}"
      if name.is_a? File
        FileUtils.cp name.path, current
        # todo: return path
      else
        path = "#{current}/#{name}"
        if contents.is_a? File
          FileUtils.cp contents.path, path
        else
          file_path = File.open(path, "w") do |f|
            f.write contents
          end
        end
        path
      end
    end
    
    def remove
      FileUtils.rm_rf(@root) if File.exists?(@root)
    end
    
    private
    def current
      @dirs.join('/')
    end
    
  end
end

def Files options = Files.default_options, &block
  files = Files.create options, &block
  files.root
end
