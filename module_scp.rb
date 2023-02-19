#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

require 'net/scp'
require 'fileutils'
require 'zip'

module SCP
    def compress(local_file, file_name)
        dest_dir = File.expand_path(local_file)
        dest_file = File.join(dest_dir, '..', file_name)
        
        puts "#{local_file} ===> #{dest_dir} compress #{dest_file} ..."

        if !File.exist?(dest_file)
            puts "File does not exist."
        end

        puts "#{dest_file} loading..."

        begin
            Zip::File.open(dest_file, Zip::File::CREATE) do |zipfile|
                puts "entry #{zipfile}"
                Dir.chdir(dest_dir) do
                    Dir[File.join('**', '**')].each do |file|
                        if zipfile.find_entry(file)
                            puts "File already exists in the zip file: #{zipfile.find_entry(file)}, #{dest_file}" 
                        elsif zipfile.glob(file).any?
                            puts "File already exists in the zip file."
                        else
                            # relative_path = file.sub(/^#{Regexp.escape(local_file + '/')}/, '')
                            # puts "Path: #{relative_path}"
                            # zipfile.add(relative_path, file)
                            # zipfile.add(file.sub(local_file + "/", ''), file)
                            if File.exist?(file)
                                puts "Add: #{file}, #{file.sub(dest_dir + '/', '')}"
                                # zipfile.add(file, file)
                                zipfile.add(file.sub(dest_dir + '/', ''), file)
                            end
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

    def move(file_path, target_path)
        FileUtils.mkdir_p(target_path) unless File.directory?(target_path)

        FileUtils.mv(file_path, target_path)
        
        File.delete(file_path)
    end

    def unCompressfile(zip_file, target_dir)
        Zip::File.open(zip_file) do |zipfile|
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
