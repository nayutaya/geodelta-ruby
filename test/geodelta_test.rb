
require_relative "./minitest_helper"

class TestGeoDelta < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GeoDelta::VERSION
  end

  def test_it_does_something_useful
    assert true
  end
end