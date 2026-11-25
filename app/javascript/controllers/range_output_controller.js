import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output", "toggle"]
  static values = { prefix: { type: String, default: "" } }

  connect() {
    this.update()
  }

  update() {
    if (this.hasToggleTarget && this.toggleTarget.checked) {
      this.inputTarget.disabled = true
      this.outputTarget.textContent = "Flexible"
      return
    }

    this.inputTarget.disabled = false
    const number = Number(this.inputTarget.value)
    this.outputTarget.textContent = this.prefixValue + number.toLocaleString("ja-JP")
  }
}
