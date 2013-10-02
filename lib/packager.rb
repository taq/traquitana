require "tmpdir"
require "zip"

module Traquitana
   class Packager
      attr_reader :id
      attr_accessor :verbose

      def initialize(dir="")
         @dir     = dir
         @id      = Time.now.strftime("%Y%m%d%H%M%S%L")
         @verbose = verbose
      end

      def list_file
         "#{@id}.list"
      end

      def zip_file
         "#{@id}.zip"
      end

      def pack
         list_path   = "#{Dir.tmpdir}/#{self.list_file}"
         zip_path    = "#{Dir.tmpdir}/#{self.zip_file}"
         list        = Traquitana::Selector.new(@dir).files
         regex       = @dir.to_s.size<1 ? "" : Regexp.new("^#{@dir}") 

         # write list file
         STDOUT.puts "Creating the list file: #{list_path}" if @verbose
         File.open(list_path,"w") {|file| file << list.map {|f| f.sub(regex,"")}.join("\n") }

         # write zip file
         STDOUT.puts "Creating the zip file : #{zip_path}" if @verbose
         Zip::File.open(zip_path ,"w") do |zip_file|
            for file in list
               strip = file.sub(regex,"")
               zip_file.add(strip,file)
            end
         end
         [list_path,zip_path]
      end
   end
end
