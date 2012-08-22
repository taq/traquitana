module Traquitana
   class Selector
      def initialize(dir="")
         @dir = dir
      end

      def files
         config = Traquitana::Config.instance
         selected = []
         for file in config.list
            send, *ignore = *file
            mask = "#{@dir}#{send}"
            send_list = Dir.glob(mask).select { |f| File.file?(f) }
            for ignore_mask in ignore
               mask = "#{@dir}#{ignore_mask}"
               ignore_list = Dir.glob(mask).select { |f| File.file?(f) }
               send_list = send_list - ignore_list if ignore_list.size>0
            end
            selected.push(*send_list)
         end
         selected
      end
   end
end
