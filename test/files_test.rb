require "wrong"
include Wrong

here = File.dirname __FILE__
$LOAD_PATH.unshift File.join(here, '..', 'lib')
require "files"

dir = Files.create do       # creates a temporary directory inside Dir.tmpdir
  file "hello.txt"          # creates file "hello.txt" containing "contents of hello.txt"
  dir "web" do              # creates directory "web"
    file "snippet.html",    # creates file "web/snippet.html"...
      "<h1>File under F for fantastic!</h1>"  # ...containing "<h1>File under F for fantastic!</h1>"
    dir "img" do            # creates directory "web/img"
      file File.new("#{here}/data/cheez_doing_it_wrong.jpg")  # containing a copy of cheez_doing_it_wrong.jpg
      file "other.jpg",     # and a different named file...
        File.new("#{here}/data/cheez_doing_it_wrong.jpg")  # containing the content of cheez_doing_it_wrong.jpg
    end
  end
end

assert { File.read("#{dir}/hello.txt") == "contents of hello.txt" }
assert { File.read("#{dir}/web/snippet.html") == "<h1>File under F for fantastic!</h1>" }
assert { 
  File.read("#{dir}/web/img/cheez_doing_it_wrong.jpg") ==
  File.read("#{here}/data/cheez_doing_it_wrong.jpg")
}
assert { 
  File.read("#{dir}/web/img/other.jpg") ==
  File.read("#{here}/data/cheez_doing_it_wrong.jpg")
}

dir = Files do
  file "hello.txt"
  dir("web") { file "hello.html" }
end
assert { File.read("#{dir}/hello.txt") == "contents of hello.txt" }
assert { File.read("#{dir}/web/hello.html") == "contents of hello.html" }
