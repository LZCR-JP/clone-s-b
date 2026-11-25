import { Controller } from "@hotwired/stimulus"

// Copies either a fixed text value or the value of a source input.
export default class extends Controller {
  static targets = ["source", "message"]
  static values = { text: String }

  async copy() {
    const text = this.hasTextValue ? this.textValue : this.sourceTarget.value

    try {
      await navigator.clipboard.writeText(text)
      this.flash("Copied! ✅")
    } catch {
      if (this.hasSourceTarget) this.sourceTarget.select()
      this.flash("Couldn't copy automatically. Please copy it manually.")
    }
  }

  flash(message) {
    if (!this.hasMessageTarget) return

    this.messageTarget.textContent = message
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.messageTarget.textContent = ""
    }, 2000)
  }
}
