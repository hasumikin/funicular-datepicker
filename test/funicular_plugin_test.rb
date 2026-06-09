# frozen_string_literal: true

require_relative "test_helper"

class FunicularPluginTest < Minitest::Test
  def test_picotests
    result = Funicular::Testing.run!(
      app_root: File.expand_path("..", __dir__),
      source_dir: File.expand_path("../lib", __dir__),
      test_glob: "test/**/*_picotest.rb",
      timeout_ms: 10_000
    )
    Funicular::Testing.assert_picotests(self, result)
  end
end
