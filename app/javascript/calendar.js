import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import jaLocale from '@fullcalendar/core/locales/ja'

document.addEventListener('turbo:load', () => {
  const calendarEl = document.getElementById('calendar')
  if (!calendarEl) return

  const projectId = calendarEl.dataset.projectId

  const calendar = new Calendar(calendarEl, {
    plugins: [dayGridPlugin],
    initialView: 'dayGridMonth',
    locale: jaLocale,
    headerToolbar: {
      left: 'prev,next today',
      center: 'title',
      right: ''
    },

    // Ajax でイベントを取得
    events: function(info, successCallback, failureCallback) {
      fetch(`/projects/${projectId}/shifts/fetch?start=${info.startStr}&end=${info.endStr}`)
        .then(response => response.json())
        .then(data => {
          let events = []

          // カレンダー範囲の日付を全部「未作成」にする
          const startDate = new Date(info.start)
          const endDate = new Date(info.end)
          for (let d = new Date(startDate); d < endDate; d.setDate(d.getDate() + 1)) {
            const dateStr = d.toISOString().split('T')[0]
            events.push({
              start: dateStr,
              extendedProps: {
                type: "new",
                url: `/projects/${projectId}/shifts/step1?date=${dateStr}`
              }
            })
          }

          // DBにある日付を「参照アイコン」に上書き
          data.forEach(shift => {
            const dateStr = shift.shift_date.split('T')[0]
            events = events.filter(e => e.start !== dateStr)
            events.push({
              start: dateStr,
              extendedProps: {
                type: "created",
                url: `/projects/${projectId}/shifts/${shift.id}/confirm`
              }
            })
          })

          successCallback(events)
        })
        .catch(failureCallback)
    },

    eventBackgroundColor: 'transparent',
    eventBorderColor: 'transparent',

    eventContent: function(arg) {
      let icon = document.createElement("i")
      if (arg.event.extendedProps.type === "new") {
        icon.className = "bi bi-plus-square text-success fs-4"
      } else {
        icon.className = "bi bi-filetype-pdf text-danger fs-3 fw-bold"
      }
      let link = document.createElement("a")
      link.href = arg.event.extendedProps.url
      link.appendChild(icon)
      return { domNodes: [link] }
    }
  })

  calendar.render()
})