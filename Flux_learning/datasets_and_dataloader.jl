using Flux, Images, ImageMagick
using DataFrames, CSV
# lets create an abstract datatype for our dataset

abstract type Dataset end

# Now we can start create the struct of our dataset
# The ImageDataset struct will be a subtype (indicated by <:)
# of Dataset type

struct ImageDataset <: Dataset
	filenames::Vector{String}
	labels::Vector
	resize::Union{Nothing, Tuple{Int}}

	function ImageDataset(filenames, labels; resize=nothing)
		@assert length(filenames) == lenght(labels)
		new(filenames, labels, resize)
	end
end

# now we add a method to our ImageDataset to know the length
# of the dataset

Base.length(ds::ImageDataset) = lenght(ds.filenames)

# and now we add a function to get the image for a giving 
# index

function Base.getindex(ds::ImageDataset, idx)
	filename = ds.filenames[idx]
	img = ImageMagick.load(filename)
	img = Images.channelview(img)
	img = permutdims(img, [2,3,1])
	img = convert(Array{Float32}, img)
	if ds.resize !== nothing
		img = Images.imresize(img, ds.resize...)
	end
	return (img, ds.labels[idx])
end

df = CSV.read("/home/felipe/Datasets/imagewoof2-320/noisy_imagewoof.csv", DataFrame)

println(describe(df))
