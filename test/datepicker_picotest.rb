class DatePickerComponentTest < Funicular::Testing::DOMTest
  def selector_count(selector)
    JS.eval("document.querySelectorAll(" + JSON.generate(selector) + ").length").to_i
  end

  def input_value(selector = ".funicular-date-picker__input")
    query(selector)[:value].to_s
  end

  def attribute(selector, name)
    value = JS.eval(
      "document.querySelector(" + JSON.generate(selector) + ")" \
        + ".getAttribute(" + JSON.generate(name) + ")"
    )
    value.nil? ? nil : value.to_s
  end

  def assert_equal_value(expected, actual)
    report(
      expected == actual,
      "Expected values to be equal",
      expected,
      actual
    )
  end

  class FakeTarget
    def initialize(value)
      @value = value
    end

    def [](key)
      key == :value ? @value : nil
    end
  end

  class FakeEvent
    attr_reader :target

    def initialize(value)
      @target = FakeTarget.new(value)
    end
  end

  def test_calendar_button_opens_panel
    mount Funicular::Plugins::DatePicker::Component, value: "2000-01-02"

    click ".funicular-date-picker__button"
    assert_selector ".funicular-date-picker__panel"
  end

  def test_focus_opens_panel
    mount Funicular::Plugins::DatePicker::Component, value: "2000-01-02"

    dispatch ".funicular-date-picker__input", "focus"

    assert_selector ".funicular-date-picker__panel"
  end

  def test_renders_value_placeholder_and_custom_input_class
    mount Funicular::Plugins::DatePicker::Component,
          value: "2000-01-02",
          placeholder: "Birthday",
          input_class: "birthday-input"

    assert_equal_value "2000-01-02", input_value(".birthday-input")
    assert_equal_value "Birthday", attribute(".birthday-input", "placeholder")
  end

  def test_renders_custom_button_class
    mount Funicular::Plugins::DatePicker::Component,
          value: "2000-01-02",
          button_class: "birthday-calendar-button"

    assert_selector ".birthday-calendar-button"
  end

  def test_input_calls_on_change
    changed = nil
    component = mount Funicular::Plugins::DatePicker::Component,
                      value: "2000-01-02",
                      on_change: ->(value) { changed = value }

    component.handle_input(FakeEvent.new("2001-02-03"))

    assert_equal_value "2001-02-03", changed
  end

  def test_select_day_calls_on_change
    selected = nil
    component = mount Funicular::Plugins::DatePicker::Component,
                      value: "2000-01-02",
                      on_change: ->(value) { selected = value }

    component.select_day(1)
    drain

    assert_equal_value "2000-01-01", selected
  end

  def test_select_day_closes_panel
    component = mount Funicular::Plugins::DatePicker::Component, value: "2000-01-02"

    click ".funicular-date-picker__button"
    component.select_day(1)
    drain

    assert_equal_value 0, selector_count(".funicular-date-picker__panel")
  end

  def test_selected_day_is_marked
    mount Funicular::Plugins::DatePicker::Component, value: "2000-01-02"

    click ".funicular-date-picker__button"

    assert_equal_value "2", text(".funicular-date-picker__day--selected")
  end

  def test_prev_and_next_month_update_header
    component = mount Funicular::Plugins::DatePicker::Component, value: "2000-01-02"

    click ".funicular-date-picker__button"
    component.prev_month
    drain
    assert_text "December 1999", ".funicular-date-picker__month"

    component.next_month
    drain
    assert_text "January 2000", ".funicular-date-picker__month"
  end

  def test_clear_calls_on_change_and_closes_panel
    changed = :not_called
    component = mount Funicular::Plugins::DatePicker::Component,
                      value: "2000-01-02",
                      on_change: ->(value) { changed = value }

    click ".funicular-date-picker__button"
    component.clear
    drain

    assert_equal_value "", changed
    assert_equal_value 0, selector_count(".funicular-date-picker__panel")
  end

  def test_close_hides_panel_without_change
    changed = :not_called
    component = mount Funicular::Plugins::DatePicker::Component,
                      value: "2000-01-02",
                      on_change: ->(value) { changed = value }

    click ".funicular-date-picker__button"
    component.close_calendar
    drain

    assert_equal_value :not_called, changed
    assert_equal_value 0, selector_count(".funicular-date-picker__panel")
  end

  def test_leap_year_february_has_29_days
    mount Funicular::Plugins::DatePicker::Component, value: "2000-02-01"

    click ".funicular-date-picker__button"

    assert_equal_value 29, selector_count(".funicular-date-picker__day")
  end

  def test_non_leap_year_february_has_28_days
    mount Funicular::Plugins::DatePicker::Component, value: "1900-02-01"

    click ".funicular-date-picker__button"

    assert_equal_value 28, selector_count(".funicular-date-picker__day")
  end
end
