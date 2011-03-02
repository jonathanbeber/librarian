require 'fileutils'
require 'pathname'

require 'librarian/chef/manifest'

module Librarian
  module Chef
    module Source
      module Local

        class Manifest < Manifest

          class << self

            def create(source, dependency, path)
              manifest?(dependency, path) ? new(source, dependency.name, path) : nil
            end

            def manifest?(dependency, path)
              path = Pathname.new(path)
              manifest_path = manifest_path(path)
              manifest_path && check_manifest(dependency, manifest_path)
            end

            def check_manifest(dependency, manifest_path)
              manifest = read_manifest(manifest_path)
              manifest["name"] == dependency.name
            end

          end

          attr_reader :path

          def initialize(source, name, path)
            super(source, name)
            @path = Pathname.new(path)
          end

          def manifest
            @manifest ||= cache_manifest!
          end

          def cache_manifest!
            read_manifest(manifest_path(path))
          end

          def cache_version!
            manifest['version']
          end

          def cache_dependencies!
            manifest['dependencies']
          end

          def install!
            debug { "Installing #{name}-#{version}" }
            install_path = root_module.install_path.join(name)
            if install_path.exist?
              debug { "Deleting #{relative_path_to(install_path)}" }
              install_path.rmtree
            end
            debug { "Copying #{relative_path_to(path)} to #{relative_path_to(install_path)}" }
            FileUtils.cp_r(path, install_path)
          end

        end

        def manifest_class
          Manifest
        end

      end
    end
  end
end