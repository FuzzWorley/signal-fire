import { Controller } from "@hotwired/stimulus"

const PATTERNS = {
  whatsapp: /^https:\/\/chat\.whatsapp\.com\//,
  discord:  /^https:\/\/(discord\.gg|discord\.com\/invite)\//,
  telegram: /^https:\/\/t\.me\//,
  signal:   /^https:\/\/signal\.group\//,
  groupme:  /^https:\/\/groupme\.com\//,
  slack:    /^https:\/\/[\w-]+\.slack\.com\/join\//,
}

const HINTS = {
  whatsapp: "https://chat.whatsapp.com/...",
  discord:  "https://discord.gg/... or https://discord.com/invite/...",
  telegram: "https://t.me/...",
  signal:   "https://signal.group/...",
  groupme:  "https://groupme.com/...",
  slack:    "https://your-workspace.slack.com/join/...",
}

export default class extends Controller {
  static targets = ["platform", "url", "feedback"]

  connect() {
    this.validate()
  }

  validate() {
    const platform = this.platformTarget.value
    const url = this.urlTarget.value
    const pattern = PATTERNS[platform]

    if (!url) {
      this.feedbackTarget.textContent = pattern ? `Expected: ${HINTS[platform]}` : ""
      this.feedbackTarget.className = "text-xs text-stone mt-1"
      return
    }

    if (pattern && pattern.test(url)) {
      this.feedbackTarget.textContent = `✓ Valid ${platform} link`
      this.feedbackTarget.className = "text-xs text-green-700 mt-1"
    } else {
      this.feedbackTarget.textContent = `Expected format: ${HINTS[platform] || "unknown platform"}`
      this.feedbackTarget.className = "text-xs text-ember mt-1"
    }
  }
}
