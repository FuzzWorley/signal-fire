import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]
  static values  = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const remaining = this.maxValue - this.inputTarget.value.length
    this.counterTarget.textContent = `${remaining} character${remaining === 1 ? "" : "s"} remaining`
    this.counterTarget.classList.toggle("text-ember", remaining < 0)
    this.counterTarget.classList.toggle("text-stone", remaining >= 0)
  }
}
