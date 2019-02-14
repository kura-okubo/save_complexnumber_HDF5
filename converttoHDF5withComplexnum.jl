"""
HDF Convert from real_image hdf5 to compound hdf5
02/13/2019 Kurama Okubo
"""

using HDF5, BenchmarkTools

include("./save_complexnum_toHDF5.jl")

using .SaveCompToHDF5

const FFT_LOADDIR = "./FFT_realImag/"
const FFT_SAVEDIR = "./FFT_comp/"
const attrslist = ["component", "elevation_in_m", "endtime", "latitude", "longitude",
        "mad", "nfft", "nonzero", "nseg", "sampling_rate", "source_channel",
        "source_delta", "source_network", "source_npts", "source_sampling_rate",
        "source_station", "starttime", "std", "twin"]

#Define size priori for the computational speed
const nx = 36451
const ny = 47

function process()

    tmp1   = Array{Float32}(undef,nx,ny)  #for load hdf5
    tmp2   = similar(tmp1)
    fft1   = Array{Complex{Float32}}(undef,nx,ny)

    #Search h5 files
    allfiles=filter(x->x[end-2:end]==".h5",readdir(FFT_LOADDIR))

    for ii=1:length(allfiles)
            
        #Open original file to be converted into compound format
        hdf5_i=h5open(FFT_LOADDIR*allfiles[ii],"r")
        
        if isfile(FFT_SAVEDIR*allfiles[ii]) rm(FFT_SAVEDIR*allfiles[ii]) end

        hdf5_o=h5open(FFT_SAVEDIR*allfiles[ii],"w")

        #loop for each component
        for name_i in filter(x->x[end-3:end]=="real",names(hdf5_i))

            name_i=name_i[1:end-5]
            name_o = name_i
            #Save attribute
            g1 = g_create(hdf5_o, name_o*".metadata")

            for attrname in attrslist
                attrs(g1)[attrname] = read(attrs(hdf5_i[name_i*".real"]), attrname)
            end

            #Save fft array
            HDF5.readarray(hdf5_i[name_i*".real"],HDF5.hdf5_type_id(Float32),tmp1)
            HDF5.readarray(hdf5_i[name_i*".imag"],HDF5.hdf5_type_id(Float32),tmp2)

            @. fft1=tmp1+1im*tmp2

            #Save fft complex num into HDF5
            save_complexnum_toHDF5(hdf5_o, name_o, fft1, ny, nx)

        end

        close(hdf5_i)
        close(hdf5_o)
    end
end

process()
