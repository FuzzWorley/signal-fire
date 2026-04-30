import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "recurrenceInput",
    "recurringBtn", "oneTimeBtn",
    "weeklyDayField", "oneDateField"
  ]

  connect() {
    this.refresh()
  }

  selectRecurring() {
    this.recurrenceInputTarget.value = "weekly"
    this.refresh()
  }

  selectOneTime() {
    this.recurrenceInputTarget.value = "one_time"
    this.refresh()
  }

  refresh() {
    const weekly = this.recurrenceInputTarget.value === "weekly"

    this.setActive(this.recurringBtnTarget, weekly)
    this.setActive(this.oneTimeBtnTarget, !weekly)

    this.weeklyDayFieldTarget.classList.toggle("hidden", !weekly)
    this.oneDateFieldTarget.classList.toggle("hidden", weekly)

    const dateInput = this.oneDateFieldTarget.querySelector("input[type='date']")
    if (dateInput) dateInput.required = !weekly
  }

  setActive(btn, active) {
    if (active) {
      btn.classList.add("bg-ember", "text-white")
      btn.classList.remove("text-ink", "border", "border-stone/30", "bg-white")
    } else {
      btn.classList.remove("bg-ember", "text-white")
      btn.classList.add("text-ink", "border", "border-stone/30", "bg-white")
    }
  }
}
