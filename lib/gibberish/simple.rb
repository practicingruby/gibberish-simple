# coding: UTF-8

require "yaml"

module Gibberish
  
  module Simple

    module Localize

      def default_language
        @default_language ||= :en
      end

      attr_writer :default_language

      def languages
        @languages ||= {}
      end

      def language_names
        languages.keys
      end

      def current_language
        @current_language || default_language
      end

      def current_language=(language)
        load_languages! 

        language = language.to_sym if language.respond_to? :to_sym
        @current_language = languages[language] ? language : nil
      end

      def use_language(language)
        start_language = current_language
        self.current_language = language
        yield
        self.current_language = start_language
      end

      def default_language?
        current_language == default_language
      end

      def translations
        languages[current_language] || {}
      end

      def translate(string, key, *args)
        target = translations[key] || string
        interpolate_string(target.dup, *args.dup)
      end

      def load_languages!
        language_files.each do |file| 
          key = File.basename(file, '.*').to_sym
          languages[key] ||= {}
          languages[key].merge!(language_data(file))
        end
        languages.keys
      end

      def language_paths
        @language_paths ||= []
      end

      private
      
      def interpolate_string(string, *args)
        if args.last.is_a? Hash
          interpolate_with_hash(string, args.last)
        else
          interpolate_with_strings(string, args)
        end
      end

      def interpolate_with_hash(string, hash)
        hash.inject(string) do |target, (search, replace)|
          target.sub("{#{search}}", replace)
        end 
      end

      def interpolate_with_strings(string, strings)
        string.gsub(/\{\w+\}/) { strings.shift }
      end
      
      def language_files
        language_paths.map {|path| 
          Dir[File.join(path, 'lang', '*.{yml,yaml}')]}.flatten
      end

      def language_data(file)
        YAML.load_file(file).each_with_object({}) do |(key,value), h|
          h[key.to_sym] = value
        end
      end
    end

    extend Gibberish::Simple::Localize

    def T(string, *args)
      args.flatten!
      Gibberish::Simple.translate(string, args.shift, *args)
    end

    module_function :T
  end
end
