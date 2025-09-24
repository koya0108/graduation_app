import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  update(event) {
    const select = event.target
    const id = select.dataset.shiftDetailId
    const field = select.dataset.field
    const value = select.value

    // 同じ行の hidden の group_id を拾う
    const row = select.closest("tr[data-shift-detail-id]")
    const groupInput = row.querySelector('input[name="group_id"]')
    const groupId = groupInput ? groupInput.value : null

    // 前回の値を保存（必ず変更前を記録する）
    if (!select.dataset.previousValue) {
      select.dataset.previousValue = value
    }

    fetch(`/shift_details/${id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        shift_detail: {
          [field]: value,
          group_id: groupId   // ← 常に送る
        }
      })
    })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          // 成功 → 今回の値を新しい previousValue として保存
          select.dataset.previousValue = value
          this.refreshRow(data.detail)
        } else {
          // 失敗 → アラート表示 & 前の値に戻す
          alert("更新に失敗しました: " + data.errors.join(", "))

          // セレクトを前の状態に戻す
          select.value = select.dataset.previousValue

          // 色はDB側の状態（detail）でリフレッシュ
          if (data.detail) {
            this.refreshRow(data.detail)
          }
        }
      })
      .catch(() => {
        alert("通信エラーが発生しました。")
        select.value = select.dataset.previousValue
      })
  }

  refreshRow(detail) {
    const row = document.querySelector(`tr[data-shift-detail-id="${detail.id}"]`)
    if (!row) return

    // リセット
    row.querySelectorAll("td.time-cell").forEach(td => td.classList.remove("bg-info"))

    const start = parseInt(detail.rest_start_time, 10)
    const end   = parseInt(detail.rest_end_time, 10)

    row.querySelectorAll("td.time-cell").forEach(td => {
      const cellHour = parseInt(td.dataset.hour, 10)
      if (cellHour >= start && cellHour < end) {
        td.classList.add("bg-info")
      }
    })
  }
}