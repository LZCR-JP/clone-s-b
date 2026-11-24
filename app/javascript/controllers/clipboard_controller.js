import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "message"]

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value)

    this.messageTarget.textContent = "Copied! ✅"

    setTimeout(() => {
      this.messageTarget.textContent = ""
    }, 2000)
  }
}

