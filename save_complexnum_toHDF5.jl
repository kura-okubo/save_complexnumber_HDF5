module SaveCompToHDF5
export save_complexnum_toHDF5
using HDF5

"""
Save complex number into HDF5
"""

function save_complexnum_toHDF5(fo::HDF5File, groupname::String, fft_comp::Array{Complex{Float32},2}, rows::Int, cols::Int)

    #Define complex array in the group
    d_type_array = HDF5.h5t_array_create(HDF5.hdf5_type_id(Float32), 1, [2])
    space = HDF5.h5s_create_simple(2, [rows, cols], [rows, cols]);
    dset_array = HDF5.h5d_create(fo, groupname*".array", d_type_array,space, HDF5.H5P_DEFAULT, HDF5.H5P_DEFAULT, HDF5.H5P_DEFAULT);
    #Save complex array
    HDF5.h5d_write(dset_array, d_type_array, HDF5.H5S_ALL, HDF5.H5S_ALL, HDF5.H5P_DEFAULT, fft_comp);

    #close temporal ID
    HDF5.h5t_close(d_type_array);
    HDF5.h5s_close(space);
    HDF5.h5d_close(dset_array);

    return 0
end

end