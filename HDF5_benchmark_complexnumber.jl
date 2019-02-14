"""
HDF loading test
02/13/2019 Kurama Okubo
"""

using HDF5, BenchmarkTools, Plots
#d_type_array used to load the complex number from HDF5
const d_type_array = HDF5.h5t_array_create(HDF5.hdf5_type_id(Float32), 1, [2])

const FFTDIR = "./FFT_realimag/"
const FFTDIR_comp = "./FFT_comp/"
const nx = 36451
const ny = 47

#-----------------------------------------------------#
#Functions for data loading
#-----------------------------------------------------#

#Case1: loading real and image separately
function loadHDF5(tmp1,tmp2,fft1,dat,name)
    HDF5.readarray(dat[name*".real"],HDF5.hdf5_type_id(Float32),tmp1)
    HDF5.readarray(dat[name*".imag"],HDF5.hdf5_type_id(Float32),tmp2)
    @. fft1=tmp1+1im*tmp2
end

#Case2: loading complex number
function loadHDF5_complexarray!(fft1::AbstractArray, dat::HDF5File, name::String, nx::Int, ny::Int)
    HDF5.h5d_read(dat[name*".array"].id, d_type_array, HDF5.H5S_ALL, HDF5.H5S_ALL, HDF5.H5P_DEFAULT, fft1);
end

#Test case 1
function process1(N::Int)
	#Read N times
	for i = 1:N
		hdf5_1 = h5open(FFTDIR*"N.AWNH.h5","r")
		loadHDF5(tmp1,tmp2,fft_s1,hdf5_1,name)
		close(hdf5_1)
	end
end

#Test case 2
function process2(N::Int)
	#Read N times
	for i = 1:N
		hdf5_2 = h5open(FFTDIR_comp*"N.AWNH.h5","r")
		loadHDF5_complexarray!(fft_s2, hdf5_2, name, nx, ny)
		close(hdf5_2)
	end
end

#-----------------------------------------------------#
#Run the test
#-----------------------------------------------------#

tmp1   = Array{Float32}(undef,nx,ny)  #for load hdf5
tmp2   = similar(tmp1)

fft_s1 = Array{Complex{Float32}}(undef,nx,ny)
fft_s2 = Array{Complex{Float32}}(undef,nx,ny)

name ="fft_N_AWNH_EHZ_2010_01_10"

N = [1, 5, 10, 20, 50, 100, 500, 1000, 2000, 5000, 10000]

elapsedtime1 = Array{Float64,1}(undef,length(N))
elapsedtime2 = similar(elapsedtime1)

println("Loading test start: it takes a few minutes.")

for i = 1:length(N)
	elapsedtime1[i] = @elapsed process1(N[i])
	elapsedtime2[i] = @elapsed process2(N[i])
end

#-----------------------------------------------------#
#Plot result
#-----------------------------------------------------#

p1 = plot(N, elapsedtime1, line=(:black, 2, :solid),
	marker = (:rect, 3, :black),
    ylabel  = "Computational Time [s]", 
    xlabel  = "Number of loading files",
    label   = "Loading real and image separately",
    xscale  =:log10,
    yscale  =:log10,
    legend  =:topleft
    )

p1 = plot!(N, elapsedtime2, line=(:red, 2, :solid),
	marker = (:rect, 3, :red),
    label   = "Loading complex array"
    )

plot(p1, size = (600, 600))

savefig("./Loadingcomparison.png")