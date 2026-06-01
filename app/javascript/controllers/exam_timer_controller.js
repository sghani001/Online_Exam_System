import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { endTime: String }

  connect() {
    this.timerEl = this.element.querySelector('.exam-timer-value')
    this.endTime = this.endTimeValue ? new Date(this.endTimeValue) : null
    this.update = this.update.bind(this)

    if (this.endTime && this.timerEl) {
      this.update()
      this.interval = setInterval(this.update, 1000)
    } else if (this.timerEl) {
      this.timerEl.textContent = '--:--'
    }
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  update() {
    const now = new Date()
    const diff = Math.max(0, Math.floor((this.endTime - now) / 1000))
    const minutes = Math.floor(diff / 60)
    const seconds = diff % 60
    this.timerEl.textContent = `${String(minutes).padStart(2,'0')}:${String(seconds).padStart(2,'0')}`

    if (diff <= 0) {
      clearInterval(this.interval)
      // Auto-submit when timer reaches zero
      const submitUrl = this.timerEl.dataset.submitUrl || this.element.dataset.submitUrl
      if (submitUrl) {
        const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        fetch(submitUrl, {
          method: 'POST',
          headers: {
            'X-CSRF-Token': token,
            'Accept': 'text/vnd.turbo-stream.html'
          }
        }).catch(err => console.warn('Auto-submit failed', err))
      } else {
        // fallback: reload to trigger server-side check
        window.location.reload()
      }
    }
  }
}
