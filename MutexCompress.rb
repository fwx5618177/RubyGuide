require "zlib"
require 'fileutils'

module MutexCompress
    class CompressThread
        def initialize(chunk, ouput_dir)
            @chunk = chunk
            @ouput_dir = ouput_dir
        end

        def run
            compressed_chunk = Zlib::Deflate.deflate(@chunk)

            ouput_dir = File.join(@ouput_dir, "chunk_#{Thread.current.object_id}.zip")

            File.open(ouput_dir, "wb") do |f|
                f.write(compressed_chunk)
            end
        end
    end

    def self.split_file(file_path, chunk_size)
        chunks = []
        offset = 0

        File.open(file_path, "rb") do |f|
            while !f.eof?
                chunk = f.read(chunk_size)
                chunks << chunk
                offset += chunk_size

                puts "Id: #{Thread.current.object_id}"
            end
        end

        chunks
    end

    def self.compress_file(file_path, ouput_dir, chunk_size, thread_count)
        FileUtils.mkdir_p(ouput_dir) unless File.directory?(ouput_dir)

        chunks = split_file(file_path, chunk_size)

        threads = []
        semaphore = Mutex.new

        chunks.each do |chunk|
            semaphore.synchronize do
                while threads.size >= thread_count
                    threads = threads.select(&:alive?)
                    sleep(0.1)
                end
            end

            thread = Thread.new { CompressThread.new(chunk, ouput_dir).run }
            threads << thread
        end

        threads.each(&:join)

        compressed_files = Dir.glob(File.join(ouput_dir, "*.zip"))
        compressed_files.sort
    end
    
end