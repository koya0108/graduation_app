// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

import "./calendar"

import TomSelect from "tom-select"

document.addEventListener("turbo:load", () => {
  document.querySelectorAll('.tom-select').forEach((el) => {
    new TomSelect(el, {
      plugins: ['remove_button'],   // タグに×ボタンを付ける
      placeholder: '選択してください',
      maxItems: null                // 制限なし（null）
    })
  })
})