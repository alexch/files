# Files

*a simple DSL for creating temporary files and directories*

## Usage

    require "files"

    files = Files do     # creates a temporary directory inside Dir.tmpdir
      file "hello.txt"          # creates file "hello.txt" containing "contents of hello.txt"
      dir "web" do              # creates directory "web"
        file "snippet.html",    # creates file "web/snippet.html"...
          "<h1>Fix this!</h1>"  # ...containing "<h1>Fix this!</h1>"
        dir "img" do            # creates directory "web/img"
          file File.new("data/hello.png")            # containing a copy of hello.png
          file "hi.png", File.new("data/hello.png")  # and a copy of hello.png named hi.png
        end
      end
    end                         # returns a string with the path to the directory

see `test/files_test.rb` for more examples

## Details

* the directory will be removed at exit
  * unless you pass `:remove => false`
* the directory name is based on the name of the source file you called Files from

## TODO

* :path option -- specifying the parent of the temporary dir (default: Dir.tmpdir)
* take a hash
* take a YAML file or string
* emit a hash
* emit a YAML file or string
* support symlinks (?)
* specify file write mode
* copy an entire data dir
* play nice with FakeFS (possibly with a :fake option)
* mixin mode -- so you can say "file" or "dir" directly, and it stores the dir in an instance variable and reuses it
* global/default :remove option
