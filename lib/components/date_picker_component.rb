class DatePickerComponent < Funicular::Component
  WEEKDAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  MONTH_NAMES = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ]

  def initialize_state
    year, month, = parse_date(props[:value])
    today_year, today_month = today_parts

    {
      calendar_open: false,
      view_year: year || today_year,
      view_month: month || today_month
    }
  end

  def open_calendar
    year, month, = parse_date(props[:value])
    patch(
      calendar_open: true,
      view_year: year || state.view_year,
      view_month: month || state.view_month
    )
  end

  def close_calendar
    patch(calendar_open: false)
  end

  def prev_month
    if state.view_month == 1
      patch(view_year: state.view_year - 1, view_month: 12)
    else
      patch(view_month: state.view_month - 1)
    end
  end

  def next_month
    if state.view_month == 12
      patch(view_year: state.view_year + 1, view_month: 1)
    else
      patch(view_month: state.view_month + 1)
    end
  end

  def clear
    emit_change("")
    patch(calendar_open: false)
  end

  def handle_input(event)
    emit_change(event.target[:value].to_s)
  end

  def select_day(day)
    value = date_string(state.view_year, state.view_month, day)
    emit_change(value)
    patch(calendar_open: false)
  end

  def render
    div(class: "funicular-date-picker") do
      div(class: "funicular-date-picker__input_row") do
        input(
          type: "text",
          value: props[:value].to_s,
          placeholder: props[:placeholder] || "YYYY-MM-DD",
          class: props[:input_class] || "funicular-date-picker__input",
          oninput: :handle_input,
          onfocus: -> { open_calendar }
        )
        button(type: "button", class: button_class, onclick: -> { open_calendar }) { "Calendar" }
      end

      render_calendar if state.calendar_open
    end
  end

  private

  def button_class
    props[:button_class] || "funicular-date-picker__button"
  end

  def render_calendar
    div(class: "funicular-date-picker__panel") do
      div(class: "funicular-date-picker__header") do
        button(type: "button", class: "funicular-date-picker__nav", onclick: -> { prev_month }) { "<" }
        div(class: "funicular-date-picker__month") do
          "#{MONTH_NAMES[state.view_month - 1]} #{state.view_year}"
        end
        button(type: "button", class: "funicular-date-picker__nav", onclick: -> { next_month }) { ">" }
      end

      div(class: "funicular-date-picker__grid") do
        WEEKDAYS.each do |day|
          div(class: "funicular-date-picker__weekday") { day }
        end

        first_weekday(state.view_year, state.view_month).times do
          div(class: "funicular-date-picker__empty") { "" }
        end

        selected_year, selected_month, selected_day = parse_date(props[:value])
        (1..days_in_month(state.view_year, state.view_month)).each do |day|
          selected = selected_year == state.view_year &&
                     selected_month == state.view_month &&
                     selected_day == day
          button(
            type: "button",
            class: selected ? "funicular-date-picker__day funicular-date-picker__day--selected" : "funicular-date-picker__day",
            onclick: -> { select_day(day) }
          ) do
            day.to_s
          end
        end
      end

      div(class: "funicular-date-picker__footer") do
        button(type: "button", class: "funicular-date-picker__footer_button", onclick: -> { clear }) { "Clear" }
        button(type: "button", class: "funicular-date-picker__footer_button", onclick: -> { close_calendar }) { "Close" }
      end
    end
  end

  def emit_change(value)
    callback = props[:on_change]
    callback.call(value) if callback
  end

  def parse_date(value)
    return [nil, nil, nil] if value.nil?

    parts = value.to_s.split("-")
    return [nil, nil, nil] unless parts.size == 3

    year = parts[0].to_i
    month = parts[1].to_i
    day = parts[2].to_i
    return [nil, nil, nil] if year < 1 || month < 1 || month > 12
    return [nil, nil, nil] if day < 1 || day > days_in_month(year, month)

    [year, month, day]
  end

  def today_parts
    now = Time.now
    [now.year, now.month]
  rescue
    [2000, 1]
  end

  def days_in_month(year, month)
    case month
    when 2
      leap_year?(year) ? 29 : 28
    when 4, 6, 9, 11
      30
    else
      31
    end
  end

  def leap_year?(year)
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
  end

  def first_weekday(year, month)
    offsets = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
    y = month < 3 ? year - 1 : year
    (y + y / 4 - y / 100 + y / 400 + offsets[month - 1] + 1) % 7
  end

  def date_string(year, month, day)
    "#{pad(year, 4)}-#{pad(month, 2)}-#{pad(day, 2)}"
  end

  def pad(number, width)
    text = number.to_s
    text = "0#{text}" while text.length < width
    text
  end
end
