import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { totemId: Number, favoriteId: String, favorited: Boolean }

  toggle() {
    if (this.favoritedValue) {
      this.#destroy()
    } else {
      this.#create()
    }
  }

  async #create() {
    const res = await fetch("/totem_favorites", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken() },
      body: JSON.stringify({ totem_id: this.totemIdValue })
    })
    if (!res.ok) return
    const data = await res.json()
    this.favoriteIdValue = String(data.id)
    this.favoritedValue  = true
    this.#updateUI()
  }

  async #destroy() {
    const res = await fetch(`/totem_favorites/${this.favoriteIdValue}`, {
      method: "DELETE",
      headers: { "X-CSRF-Token": csrfToken() }
    })
    if (!res.ok) return
    this.favoriteIdValue = ""
    this.favoritedValue  = false
    this.#updateUI()
  }

  #updateUI() {
    const favorited = this.favoritedValue
    this.element.setAttribute("aria-pressed", favorited)
    this.element.setAttribute("aria-label", favorited ? "Remove from favorites" : "Add to favorites")
    const polygon = this.element.querySelector("polygon")
    if (polygon) polygon.setAttribute("fill", favorited ? "#1a1a12" : "none")
  }
}

function csrfToken() {
  return document.querySelector("meta[name=csrf-token]")?.content ?? ""
}
