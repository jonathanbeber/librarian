require 'librarian/dsl'
require 'librarian/mock/particularity'
require 'librarian/mock/source'

module Librarian
  module Mock
    class Dsl < Librarian::Dsl

      include Particularity

      dependency :dep

      source :src => Source::Mock

      shortcut :a, :src => 'source-a'
    end
  end
end
