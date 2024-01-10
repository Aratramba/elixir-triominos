// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import triominos from "./triominos"

let Hooks = {}

const dragger = document.getElementById('dragger')
dragger.addEventListener('pointermove', onMouseMove.bind(this), false);
let x, y;

function onMouseMove(e) {
  x = e.clientX;
  y = e.clientY;
}

Hooks.Board = {
  x: -500,
  y: -1000,
  dragX: 0,
  dragY: 0,
  move() {
    this.el.style.transform = `translateX(${this.x}px) translateY(${this.y}px) translateZ(0)`
  },
  mounted() {
    this.move();

    onBoardDragStart = _onBoardDragStart.bind(this)
    dragger.addEventListener('pointerdown', onBoardDragStart);

    function _onBoardDragStart(e) {
      const clickedElements = document.elementsFromPoint(e.clientX, e.clientY);
      const draggablePiece = clickedElements.find(element => element.hasAttribute('data-draggable'))

      if (draggablePiece) return;
      this.dragX = e.clientX;
      this.dragY = e.clientY;

      onBoardDrag = _onBoardDrag.bind(this)
      onBoardDragEnd = _onBoardDragEnd.bind(this)
      dragger.addEventListener('pointermove', onBoardDrag);
      dragger.addEventListener('pointerup', onBoardDragEnd);
    }

    function _onBoardDrag(e) {
      e.preventDefault();
      const prevX = this.dragX;
      const prevY = this.dragY;

      this.dragX = e.clientX;
      this.dragY = e.clientY;

      this.x += this.dragX - prevX;
      this.y += this.dragY - prevY;
      this.move();
    }

    function _onBoardDragEnd(e) {
      e.preventDefault();
      dragger.removeEventListener('pointermove', onBoardDrag);
      dragger.removeEventListener('pointerup', onBoardDragEnd);
    }
  },
  updated() {
    this.move();
  }
}



Hooks.Dragging = {
  move() {
    this.el.style.transform = `translateX(${x - 50}px) translateY(${y - 43}px) translateZ(0)`
  },
  mounted() {
    const id = this.el.getAttribute('data-id')

    onKeyUp = _onKeyUp.bind(this)
    addEventListener('keyup', onKeyUp)

    onPieceDrag = _onPieceDrag.bind(this)
    onPieceDragEnd = _onPieceDragEnd.bind(this)
    dragger.addEventListener('pointermove', onPieceDrag);
    dragger.addEventListener('pointerup', onPieceDragEnd);
    this.el.style.transform = `translateX(${x - 50}px) translateY(${y - 43}px) translateZ(0)`

    function _onPieceDrag(e) {
      e.preventDefault();
      this.move();
    }

    function _onPieceDragEnd(e) {
      e.preventDefault();
      this.pushEvent('drag_end', { piece: id })
      removeEventListener('keyup', onKeyUp)
      dragger.removeEventListener('pointermove', onPieceDrag);
      dragger.removeEventListener('pointerup', onPieceDragEnd);
    }

    function _onKeyUp(e) {
      if (e.keyCode === 32) {
        this.pushEvent('rotate', { piece: id })
      }
    }
  },
  updated() {
    this.move();
  }
}

Hooks.Hand = {
  mounted() {
    const dragger = document.getElementById('dragger')

    onDragStart = _onDragStart.bind(this)
    dragger.addEventListener('pointerdown', onDragStart);

    function _onDragStart(e) {
      e.preventDefault();

      const clickedElements = document.elementsFromPoint(e.clientX, e.clientY);
      const piece = clickedElements.find(element => element.hasAttribute('data-draggable'))

      if (piece) {
        this.pushEvent('drag_start', { piece: piece.getAttribute('data-id') })
        return;
      }

    }
  },
}


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


