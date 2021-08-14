require "yaml"
require "./utility"

module OIJ
  class Config
    class_getter(config) do
      YAML.parse File.new("/home/yuruhiya/programming/oij/config/oij.yml")
    end

    private macro define_getter(key, &type_check)
      def self.{{key.id}}?
        if e = config[{{key}}]?
          {{yield}}
        end
      end

      def self.{{key.id}}
        {{key.id}}? || OIJ.error(%[Not found {{key}} in config])
      end
    end

    private macro define_getter(key, expect_type)
      define_getter({{key}}) do
        e.raw.as?({{expect_type}}) || OIJ.error(%[config[{{key}}] is not {{expect_type}}])
      end
    end

    private macro define_hash_getter(key, &type_check)
      def self.{{key.id}}?
        if elem = config[{{key}}]?
          hash = elem.as_h? || OIJ.error(%[config[{{key}}] is not Hash])
          hash.map { |e2, e|
            key = e2.as_s? || OIJ.error(%[#{e2} in config[{{key}}] is not String])
            value = {{yield}}
            {key, value}
          }.to_h
        end
      end

      def self.{{key.id}}(&block)
        {{key.id}}? || yield
      end

      def self.{{key.id}}?(key : String)
        if e = config.dig?({{key}}, key)
          {{yield}}
        end
      end

      def self.{{key.id}}(key : String)
        {{key.id}}?(key) || OIJ.error(%[config[{{key}}][#{key}] is not exists])
      end

      def self.{{key.id}}(key : String, &block)
        {{key.id}}?(key) || yield
      end
    end

    private macro define_hash_getter(key, expect_key_type)
      define_hash_getter({{key}}) do
        e.raw.as?({{expect_key_type}}) ||
          OIJ.error(%[config[{{key}}][#{key}] is not {{expect_key_type.id}}])
      end
    end

    private macro define_hash_getter2(key)
      def self.{{key.id}}?(key : String, option : String?)
        elem1 = (config[{{key}}]? || return nil).as_h? || OIJ.error(%[config[{{key}}] is not Hash])
        elem2 = elem1[key]? || return nil
        if str = elem2.as_s?
          option.nil? ? str : nil
        elsif hash = elem2.as_h?
          (hash[option || "default"]? || return nil).as_s? ||
            OIJ.error(%[config[{{key}}][#{key}][#{option}] is not String])
        else
          OIJ.error(%[config[{{key}}][#{key}] is neither String nor Hash])
        end
      end

      def self.{{key.id}}(key : String, option : String?, &block)
        {{key.id}}?(key, option) || yield
      end
    end

    # define_hash_getter "compile", String
    define_hash_getter "execute", String
    define_hash_getter "path" do
      Path[e.as_s? || OIJ.error(%[config[path][#{key}] is not String])]
    end
    define_hash_getter "bundler", String

    define_hash_getter("template") do
      array = e.as_a? || OIJ.error(%[config[template][#{key}] is not Array])
      unless array.size == 2 && array[0].as_s? && array[1].as_s?
        OIJ.error(%[config[template][#{key}] is not [String, String]])
      end
      array.map { |s| Path[s.as_s] }
    end

    define_getter "editor", String
    define_getter "printer", String

    define_getter("input_file_mapping") do
      array = e.as_a? || OIJ.error(%[config[input_file_mapping] is not Array])
      array.map_with_index do |elem, index|
        unless elem.size == 2 && elem[0].as_s? && elem[1].as_s?
          OIJ.error(%[config[input_file_mapping][#{index}] is not [String, String]])
        end
        {elem[0].as_s, elem[1].as_s}
      end
    end

    define_getter("testcase_mapping") do
      array = e.as_a || OIJ.error(%[config[testcase_mapping] is not Array])
      array.map_with_index do |elem, index|
        unless elem.size == 2 && elem[0].as_s? && elem[1].as_s?
          OIJ.error(%[config[testcase_mapping][#{index}] is not [String, String]])
        end
        {elem[0].as_s, elem[1].as_s}
      end
    end

    define_hash_getter2 "compile"
    define_hash_getter2 "execute"
  end
end
