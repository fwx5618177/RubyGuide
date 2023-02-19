#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

require 'net/scp'
require 'fileutils'
require 'zip'

module SCP
    def compress(local_file, file_name)
        dest_file = File.join(local_file, file_name)
        
        puts "#{dest_file} compress #{local_file} ..."

        if !File.exist?(local_file)
            puts "File does not exist."
        end

        Zip::File.open(dest_file, Zip::File::CREATE) do |zipfile|
            puts "entry #{zipfile}"
            Dir[File.join(local_file), '**', '**'].each do |file|
                if zipfile.find_entry(file)
                    puts "File already exists in the zip file: #{zipfile.find_entry(file)}, #{dest_file}" 
                elsif zipfile.glob(file).any?
                    puts "File already exists in the zip file."
                else
                    zipfile.add(file.sub(local_file + '/', ''), file)
                end
            end

            puts "Add all successfully!"
        
        end

        return dest_file
    end

    def move(file_path, target_path)
        FileUtils.mkdir_p(target_path) unless File.directory?(target_path)

        FileUtils.mv(file_path, target_path)
        
        File.delete(file_path)
    end

    def unCompressfile(zip_file, target_dir)
        Zip::file.open(zip_file) do |zipfile|
            zipfile.each do |file|
                fpath = File.join(target_dir, file.name)
                FileUtils.mkdir_p(File.dirname(fpath))
                zipfile.extract(file, fpath) unless File.exist?(fpath)
            end
        end

        puts "Unzip successfully."
        File.delete(zip_file)
        puts "Deleted #{zip_file} on remote machine."
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
end
