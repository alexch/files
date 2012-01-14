require "files/version"


module Files
  
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

      instance_eval &block if block
    end

    def dir name, &block
      path = "#{current}/#{name}"
      Dir.mkdir path
      @dirs << name
      instance_eval &block if block
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
    
    private
    def current
      @dirs.join('/')
    end
    
  end
end

def Files options = Files.default_options, &block
  Files.create options, &block
end
