import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "banner", "passwordSection", "magicLinkSection"]

  connect() {
    if (this.hasModalTarget) {
      this._timer = setTimeout(() => this.openModal(), 5000)
    }
  }

  disconnect() {
    clearTimeout(this._timer)
  }

  openModal() {
    if (!this.hasModalTarget) return
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  dismiss() {
    if (!this.hasModalTarget) return
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""
    if (this.hasBannerTarget) this.bannerTarget.classList.remove("hidden")
  }

  dismissBanner() {
    if (!this.hasBannerTarget) return
    this.bannerTarget.classList.add("hidden")
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.dismiss()
  }

  showMagicLink() {
    this.passwordSectionTarget.classList.add("hidden")
    this.magicLinkSectionTarget.classList.remove("hidden")
  }

  showPassword() {
    this.magicLinkSectionTarget.classList.add("hidden")
    this.passwordSectionTarget.classList.remove("hidden")
  }
}
