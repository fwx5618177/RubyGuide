require "thread"
require "zlib"

module FileCompress
    CHUNK_SIZE = 1024 * 1024

    def self.compress_file(source, target, num_threads = 4)
        file_size = File.size(source)

        num_chunks = (file_size / CHUNK_SIZE.to_f).ceil
        chunk_ranges = (0...num_chunks).map { |i| i * CHUNK_SIZE...(i+1) * CHUNK_SIZE }
        chunk_ranges[-1] = chunk_ranges[-1].begin...(file_size)

        # 创建queue保存压缩的块
        queue = Queue.new

        threads = (1..num_threads).map do
            Thread.new do
                while range = chunk_ranges.pop
                    puts "range: #{range}, source: #{source}"
                    chunk_data = File.read(source, range.size, range.begin)

                    # puts "chunk data: #{chunk_data}"
                    compress_chunk_data = Zlib::Deflate.deflate(chunk_data)

                    puts "Id: #{Thread.current.object_id}, #{range}"
                    queue << compress_chunk_data
                end
            end
        end

        threads.each(&:join)

        File.open(target, "wb") do |f|
            while !queue.empty?
                compress_chunk_data = queue.pop

                f.write(compress_chunk_data)
            end
        end
    end
end
