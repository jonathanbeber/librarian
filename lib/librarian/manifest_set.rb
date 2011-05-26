module Librarian
  class ManifestSet

    class << self
      def shallow_strip(manifests, names)
        new(manifests).shallow_strip!(names).send(method_for(manifests))
      end
      def deep_strip(manifests, names)
        new(manifests).deep_strip!(names).send(method_for(manifests))
      end
    private
      def method_for(manifests)
        case manifests
        when Hash
          :to_hash
        when Array
          :to_a
        end
      end
    end

    def initialize(manifests)
      @index = Hash === manifests ? manifests.dup : Hash[manifests.map{|m| [m.name, m]}]
    end

    def to_a
      @index.values
    end

    def to_hash
      @index.dup
    end

    def dup
      self.class.new(@index)
    end

    def shallow_strip(names)
      dup.shallow_strip!(names)
    end

    def shallow_strip!(names)
      names = [names] unless Array === names
      names.each do |name|
        @index.delete(name)
      end
      self
    end

    def deep_strip(names)
      dup.deep_strip!(names)
    end

    def deep_strip!(names)
      names = [names] unless Array === names
      names = names.dup
      until names.empty?
        name = names.shift
        manifest = @index.delete(name)
        manifest.dependencies.each do |dependency|
          names << dependency.name
        end
      end
      self
    end

    def consistent?
      @index.values.all? do |manifest|
        manifest.dependencies.all? do |dependency|
          match = @index[dependency.name]
          match && match.satisfies?(dependency)
        end
      end
    end

  end
end