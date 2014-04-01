# Copyright Swipely, Inc.  All rights reserved.

module Hasta
  # Creates instances of a class given its definition file
  module MaterializeClass
    class << self
      def from_file(file)
        require file
        snake_class = File.basename(file).split('.').first

        instantiate(camelize_name(snake_class))
      end

      private

      def camelize_name(snake_name)
        snake_name.split('_').map { |term|
          term.each_char.each_with_index.map { |ch, i| (i == 0) ? ch.upcase : ch }.join
        }.join
      end

      def instantiate(klass_name)
        Object.const_get(klass_name).new
      rescue NameError => ex
        raise ClassLoadError, ex.message, ex.backtrace
      end
    end
  end
end
