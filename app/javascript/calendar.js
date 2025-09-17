import { Calendar } from '@fullcalendar/core'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import interactionPlugin from '@fullcalendar/interaction'
import jaLocale from '@fullcalendar/core/locales/ja'

document.addEventListener('turbo:load', () => {
  const calendarEl = document.getElementById('calendar')
  if (!calendarEl) return

  const projectId = calendarEl.dataset.projectId

  if (calendarEl) {
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin],
      initialView: 'dayGridMonth',
      locale: jaLocale,
      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: ''
      },
      events: [
        {
            title: "作成済みシフト",
            start: "2025-09-21",
            extendedProps: {
                type: "created",
                url: `/projects/${projectId}/shifts/1/pdf`
            }
        },
        {
            title: "未作成",
            start: "2025-09-22",
            extendedProps: {
                type: "new",
                url: `/projects/${projectId}/shifts/new?date=2025-09-22`
            }
        }
      ],
      eventContent: function (arg) {
        let icon = document.createElement("i")
        if (arg.event.extendedProps.type === "new") {
            icon.className = "bi bi-plus-circle text-success fs-4"
        } else {
            icon.className = "bi bi-file-earmark-pdf text-primary fs-4"
        }
        let link = document.createElement("a")
        link.href = arg.event.extendedProps.url
        link.appendChild(icon)
        return { domNodes: [link] }
      }
    })
    calendar.render()
  }
})