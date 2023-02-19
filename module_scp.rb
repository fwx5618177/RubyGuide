#!/usr/bin/ruby -w
# -*- coding: UTF-8 -*-

require 'net/scp'
require 'fileutils'
require 'zip'

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

    def move(local_file, target_path)
        file_path = File.expand_path(local_file)
        FileUtils.mkdir_p(target_path) unless File.directory?(target_path)

        FileUtils.mv(file_path, target_path)
        
        # delete local file
        File.delete(file_path) if File.file?file_path
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

        # delete remote file
        File.delete(zip_file)
        puts "Deleted #{zip_file} on remote machine."
    end

    def delete_file(local_file)
        dir = File.expand_path(local_file)
        puts "Do you really want to delete #{dir}? [Y/N]: "
        answer = STDIN.gets.chomp.downcase

        if answer == 'y'
            print "exist: #{File.exist?dir}"
            FileUtils.rm_rf(dir) if File.exist?dir
            puts "Del #{dir} successfully!"
        else
            puts "Del canceled."
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
end
