import {Socket, Presence} from "phoenix"

//====== Socket
let socket = new Socket("/socket"); socket.connect()
let channel = socket.channel("room:" + window.roomToken, {})

//====== Global
let _presences = {}

//====== Elements
let $menu = document.querySelector('#menu')
let $pick = document.querySelector('#pick')
let $count = document.querySelector('#count')
let $up = document.querySelector('#up')
let $down = document.querySelector('#down')

//====== Utilities
let disableElem = (elem) => { elem.disabled = true }
let enableElem = (elem) => { elem.disabled = false }
let markAsWinner = () => { $pick.classList.add("tasty") }
let markAsNormal = () => { $pick.classList.remove("tasty") }
let updatePresences = (presences) => { $count.innerText = Object.keys(presences).length }
let updatePick = (pick, winner) => {
  if (winner) {
    markAsWinner()
  } else {
    enableElem($up)
    enableElem($down)
    markAsNormal()
  }
  if (pick) {
    $pick.innerText = pick
  } else {
    disableElem($up)
    disableElem($down)
  }
}

//====== Channel events
channel.on("pick", payload => { updatePick(payload.pick, payload.winner) })
channel.on("presence_state", state => {
  _presences = Presence.syncState(_presences, state)
  updatePresences(_presences)
})
channel.on("presence_diff", diff => {
  _presences = Presence.syncDiff(_presences, diff)
  updatePresences(_presences)
})

//====== Join channel
channel.join()
  .receive("ok", resp => { updatePick(resp.pick, resp.winner) })
  .receive("error", resp => { console.log("Unable to join", resp) })

//====== User interactions
$up.addEventListener('click', (e) => {
  disableElem($up)
  channel.push("vote", {dir: "up"})
})
$down.addEventListener('click', (e) => {
  disableElem($down)
  channel.push("vote", {dir: "down"})
})

$menu.addEventListener('keypress', (e) => {
  if (e.keyCode != 13 || $menu.value == "") return

  disableElem($menu)
  channel.push("menu", {items: $menu.value})
})

export default socket
