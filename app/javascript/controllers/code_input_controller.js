import { Controller } from "@hotwired/stimulus"

// Uppercases the join code as it's typed and drops characters a code can't contain.
export default class extends Controller {
  format() {
    const input = this.element
    const position = input.selectionStart
    const formatted = input.value.toUpperCase().replace(/[^A-Z0-9-]/g, "")

    if (formatted !== input.value) {
      const removed = input.value.length - formatted.length
      input.value = formatted
      input.setSelectionRange(position - removed, position - removed)
    }
  }
}
