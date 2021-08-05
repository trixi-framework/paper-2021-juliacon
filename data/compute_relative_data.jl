using DelimitedFiles

"""
    save_relative_data(filename_in)

Convert the absolute PIDs contained in `filename_in` and save them in another
file. The input filename `filename_in` should be of the form `some_name.dat`.
Then, the output filename will be `some_name_relative.dat`.
"""
function save_relative_data(filename_in)
  @assert endswith(filename_in, ".dat")
  filename_out = replace(filename_in, ".dat" => "_relative.dat")

  open(filename_out, "w") do io
    data, header = readdlm(filename_in, header=true)
    writedlm(io, header)
    reference = data[:, end]
    for j in 2:size(data, 2)
        data[:, j] ./= reference
    end
    writedlm(io, data)
  end
end

save_relative_data("pids_euler_kennedygruber.dat")
save_relative_data("pids_euler_ranocha.dat")
save_relative_data("pids_euler_weak.dat")
