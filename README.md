# funicular-datepicker

Date picker component for Funicular.

Use it from an application Gemfile:

```ruby
group :funicular do
  gem "funicular-datepicker"
end
```

```ruby
component(
  Funicular::Plugins::DatePicker::Component,
  value: state.birthday,
  input_class: "birthday-input",
  button_class: "birthday-calendar-button",
  on_change: ->(value) { patch(birthday: value) }
)
```
