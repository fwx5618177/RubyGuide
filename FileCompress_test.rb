require_relative "FileCompress"

source = "/Users/fengwenxuan/Desktop/ruby/empty_file"
target = "/Users/fengwenxuan/Desktop/ruby/empty_file.zip"

thread = 8

FileCompress.compress_file(source, target, thread)
