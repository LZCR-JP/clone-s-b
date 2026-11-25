require "test_helper"

class NomikaiTest < ActiveSupport::TestCase
  test "assigns a readable join code on create" do
    nomikai = create_nomikai

    assert_match(/\A[ABCDEFGHJKMNPQRSTUVWXYZ23456789]{6}\z/, nomikai.join_code)
    assert_equal "SWIPE-#{nomikai.join_code}", nomikai.formatted_join_code
  end

  test "finds by join code regardless of case, spacing, dashes or prefix" do
    nomikai = create_nomikai
    code = nomikai.join_code

    ["SWIPE-#{code}", "swipe-#{code.downcase}", " #{code} ", "swipe #{code}", code.chars.join("-")].each do |input|
      assert_equal nomikai, Nomikai.find_by_join_code(input), "expected #{input.inspect} to match"
    end
  end

  test "rejects malformed join codes" do
    create_nomikai

    assert_nil Nomikai.find_by_join_code("")
    assert_nil Nomikai.find_by_join_code("SWIPE-")
    assert_nil Nomikai.find_by_join_code("ABC")
  end

  test "regenerating the join code revokes the old one" do
    nomikai = create_nomikai
    old_code = nomikai.formatted_join_code

    nomikai.regenerate_join_code!

    assert_nil Nomikai.find_by_join_code(old_code)
    assert_equal nomikai, Nomikai.find_by_join_code(nomikai.formatted_join_code)
  end

  test "only open, upcoming events accept participants" do
    assert create_nomikai.accepting_participants?
    assert_not create_nomikai(status: "closed").accepting_participants?

    past = create_nomikai
    past.update_column(:event_date, 1.day.ago)
    assert_not past.accepting_participants?
  end
end
