import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer"]

  toggle() {
    const open = this.drawerTarget.classList.toggle("hidden")
    document.body.classList.toggle("overflow-hidden", !open)
  }

  close() {
    this.drawerTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
}
