import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sheet"]

  open(event) {
    event.preventDefault()
    this.sheetTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.sheetTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  closeOnBackdrop(event) {
    if (event.target === this.sheetTarget) this.close()
  }
}
