import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: String }

  connect() {
    this.show(this.activeValue || this.tabTargets[0]?.dataset.tab)
  }

  select(event) {
    this.show(event.currentTarget.dataset.tab)
  }

  show(name) {
    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.tab === name
      tab.classList.toggle("is-active", active)
      tab.setAttribute("aria-selected", active)
    })

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.tab !== name
    })
  }
}
