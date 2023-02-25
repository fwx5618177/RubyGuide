#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

require 'net/scp'
require 'fileutils'
require 'zip'
require 'parallel'

module SCP
    def compress(local_file, file_name)
        dest_dir = File.expand_path(local_file)
        dest_file = File.join(dest_dir, file_name)
        
        puts "#{local_file} ===> #{dest_dir} compress #{dest_file} ..."

        if File.exist?(dest_file)
            File.delete(dest_file) if File.exist?dest_file
            puts 'Delete old version.'
        end

        puts "#{dest_file} loading..."

        begin
            Zip::File.open(dest_file, create: true) do |zipfile|
                zip_path = File.basename(dest_dir)
                puts "entry #{zipfile}"

                zipfile.mkdir(zip_path)
                Dir.chdir(dest_dir) do
                    Dir[File.join('**', '**', '*')].each do |file|
                        puts "files: #{file}"
                        if zipfile.find_entry(file)
                            puts "File already exists in the zip file: #{zipfile.find_entry(file)}, #{dest_file}" 
                        elsif zipfile.glob(file).any?
                            puts "File already exists in the zip file."
                        else
                            puts "Add: #{zip_path}/#{file}"
                            zipfile.add(File.join(zip_path, file), "#{dest_dir}/#{file}")
                        end
                    end
                end
            end
        rescue Zip::Error => e
            puts "Can't find files: #{e.message}"
        end

        puts "Add all successfully!"

        return dest_file
    end

    def thread_compress(local_file, file_name, thread_nums)
        dest_dir = File.expand_path(local_file)
        puts "File or directory: #{dest_dir}, #{File.file?(dest_dir)}"
        
        if File.file?(dest_dir)
            dir_name = File.dirname(dest_dir)
            dest_file = File.join(dir_name, file_name)

            puts "dirname: #{dir_name}"
            Zip::File.open(dest_file, Zip::File::CREATE) do |zipfile|
                zipfile.add(File.basename(dest_dir), dest_dir)
            end
        else
            dest_file = File.join(dest_dir, file_name)
    
            Zip::File.open(dest_file, Zip::File::CREATE) do |zipfile|
                puts "Entry #{zipfile}"
                zip_path = File.basename(dest_dir)
                if zipfile.find_entry(zip_path)
                    puts "mkdir already."
                else
                    zipfile.mkdir(zip_path) 
                end
            
                Dir.chdir(dest_dir) do
                    Parallel.each(Dir[File.join('**', '**')], in_threads: thread_nums) do |file|
                        if zipfile.find_entry(file)
                            puts "File already exists"
                        elsif zipfile.glob(file).any?
                            puts "File already exists"
                        else
                            puts "Id: #{Thread.current.object_id}, add: #{zip_path}/#{file}"
                            zipfile.add(File.join(zip_path, file), "#{dest_dir}/#{file}")
                        end
                    end
                end
                
            end
        end



        puts "Add all successfully!"

        return dest_file
    end

    def thread_compress_entry(local_file, file_name, thread_nums)
        compress_task = Thread.new do
            thread_compress(local_file, file_name, thread_nums)
        end

        compress_task.join

        puts "Compression completed!"
    end

    def move(local_file, file_name, target_path)
        file_path = "#{File.expand_path(local_file)}/#{file_name}"
        file_path = "#{File.expand_path(File.dirname(local_file))}/dist.zip" unless File.file?local_file

        puts "#{file_path}"

        FileUtils.mkdir_p(target_path) unless File.directory?(target_path)

        FileUtils.mv(file_path, target_path)
        
        # delete local file
        File.delete(file_path) if File.file?file_path
    end

    def unCompressfile(zip_file, target_dir)
        progress = 0
        total_size = 0
        Zip::File.open(zip_file) do |zipfile|
            zipfile.each do |entry|
                total_size += entry.size
            end

            zipfile.each do |file|
                cur_size = file.size
                print_process(progress, total_size)
                $stdout.flush

                fpath = File.join(target_dir, file.name)
                FileUtils.mkdir_p(File.dirname(fpath))

                zipfile.extract(file, fpath) unless File.exist?(fpath)
                progress += cur_size
            end
        end

        puts "Unzip successfully."

        # delete remote file
        File.delete(zip_file)
        puts "Deleted #{zip_file} on remote machine."
    end

    def delete_file(local_file, force = false)
        dir = File.expand_path(local_file)

        if (force)
            FileUtils.rm_rf(dir) if File.exist?dir
            puts "Del #{dir} successfully!"
        elsif
            puts "Do you really want to delete #{dir}? [Y/N]: "
            answer = STDIN.gets.chomp.downcase
    
            if answer == 'y'
                puts "exist: #{File.exist?dir}"
                FileUtils.rm_rf(dir) if File.exist?dir
                puts "Del #{dir} successfully!"
            else
                puts "Del canceled."
            end
        end
    end

    def upload_file(host, username, pwd, local_file, remote_file)
        Net::SCP.start(host, username, :password => pwd) do |scp|
            scp.upload(local_file, remote_file)
            puts "Uploaded #{local_file} to #{remote_file} on #{host}."
        end

        File.delete(local_file)
        puts "Deleted #{local_file} on local machine."

        puts "SCP transfer complete."
    end

    def print_process(progress, total_size)
        percent = (progress / total_size * 100).round
        puts "\r正在解压,已完成:  #{percent}"
    end

    def directories_exist?(dir1, dir2)
        [dir1, dir2].all? do |dir|
            File.directory?(dir)
        end
    end

    def file_exist?(dir1, dir2, filename)
        [dir1, dir2].all? do |dir|
            File.exist?(File.join(dir, filename))
        end
    end
end
