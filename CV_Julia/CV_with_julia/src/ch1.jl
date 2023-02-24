using Pkg
Pkg.activate("../")
using Images
using ImageMetadata
using TestImages
using ImageView

pwd()

# Reading single file from HDD
sample_image_path = "/home/felipe/Imagens/gabe.jpg"

if isfile(sample_image_path)
    sample_image = load(sample_image_path)
else
    @info "Image not found"
end

# Reading from URL
img_url = "https://i.kym-cdn.com/photos/images/facebook/000/377/946/0b9.jpg"
isdir
isdir("../img_samples/") ? nothing : mkpath("../img_samples"); @info "Path for download images was created"

downloaded_image_path = download(img_url, "Rick_rol.jpg") 
downloaded_image = load(downloaded_image_path)

###
# Images in a folder

directory_path = "../img_samples/"
directory_files = readdir(directory_path)
directory_images = filter(x -> match(r"\.(jpg|png|gif){1}$"i, x), directory_files)
