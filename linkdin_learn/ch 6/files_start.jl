# Starting file system example for Learning Julia

# TODO get the current workding dir
# print("Current working directory: ")
println(pwd())
println(readdir())

# TODO read the contents of the current directory
# print("Current directory contents: ")
#createfile("mytext.txt", "helloworld")

# TODO open a file for writing
function createfile(filename::String, text::String = "some text")
	io = open(filename, "w")
	write(io, text)
	close(io)
end


# TODO open a file for reading
function readafile(filename::String)
	io = open(filename, "r")
	content = read(io, String)
	println(content)
end
readafile("mytext.txt")
# TODO append data to an existing file
function appendtofile(filename::String, text::String)
	io = open(filename, "a")
	write(io, text)
	close(io)
end
appendtofile("mytext.txt", "This was added")
readafile("mytext.txt")


# TODO rename an existing file
function renamefile(oname::String, newname::String)
	mv(oname,newname)
end
#renamefile("mytext.txt", "newmytext.txt")
println(readdir())

# TODO delete a file
