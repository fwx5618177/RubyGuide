require_relative "MutexCompress"

source = "/Users/fengwenxuan/Desktop/ruby/empty_file"
target = "/Users/fengwenxuan/Desktop/ruby/compressed_files"
chunk_size = 1024 * 1024
thread = 8

compress_file = MutexCompress.compress_file(source, target, chunk_size, thread)
puts "Compressed files successfully!"
