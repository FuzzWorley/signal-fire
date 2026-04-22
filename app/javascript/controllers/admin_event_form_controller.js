import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hostSelect", "totemSelect",
    "recurrenceInput", "recurringBtn", "oneTimeBtn",
    "weeklyDayField", "oneDateField"
  ]

  static values = { hostTotems: Object }

  connect() {
    this.refreshRecurrence()
    this.updateTotems()
  }

  hostChanged() {
    this.updateTotems()
  }

  updateTotems() {
    const hostId  = this.hostSelectTarget.value
    const totems  = this.hostTotemsValue[hostId] || []
    const select  = this.totemSelectTarget
    const current = select.dataset.current || select.value

    select.innerHTML = "<option value=\"\">Select a totem</option>"
    totems.forEach(({ id, name }) => {
      const opt = document.createElement("option")
      opt.value = id
      opt.textContent = name
      if (String(id) === String(current)) opt.selected = true
      select.appendChild(opt)
    })
  }

  selectRecurring() {
    this.recurrenceInputTarget.value = "weekly"
    this.refreshRecurrence()
  }

  selectOneTime() {
    this.recurrenceInputTarget.value = "one_time"
    this.refreshRecurrence()
  }

  refreshRecurrence() {
    const weekly = this.recurrenceInputTarget.value === "weekly"
    this.setActive(this.recurringBtnTarget, weekly)
    this.setActive(this.oneTimeBtnTarget, !weekly)
    this.weeklyDayFieldTarget.classList.toggle("hidden", !weekly)
    this.oneDateFieldTarget.classList.toggle("hidden", weekly)
  }

  setActive(btn, active) {
    if (active) {
      btn.classList.add("bg-ember", "text-white")
      btn.classList.remove("text-ink", "border-r", "border-stone/30", "bg-white")
    } else {
      btn.classList.remove("bg-ember", "text-white")
      btn.classList.add("text-ink", "border-r", "border-stone/30", "bg-white")
    }
  }
}
