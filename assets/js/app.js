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



let Hooks = {}

const dragger = document.getElementById('dragger')
dragger.addEventListener('pointermove', onMouseMove.bind(this), false);

let x;
let y;
let boardX = -2000
let boardY = -2000

const PIECE_HEIGHT = 86;
const PIECE_WIDTH = 100;

document.body.style.setProperty('--piece-height', `${PIECE_HEIGHT}px`);
document.body.style.setProperty('--piece-width', `${PIECE_WIDTH}px`);

function roundTo(n, to) {
  return Math.floor(Math.floor(n / to) * to)
}

function onMouseMove(e) {
  x = e.clientX;
  y = e.clientY;
}

Hooks.Board = {
  dragX: 0,
  dragY: 0,
  move() {
    this.el.style.transform = `translateX(${boardX}px) translateY(${boardY}px) translateZ(0)`
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

      boardX += this.dragX - prevX;
      boardY += this.dragY - prevY;

      if (boardX > 0) boardX = 0;
      if (boardY > 0) boardY = 0;
      if (boardX < -4000) boardX = -4000;
      if (boardY < -4000) boardY = -4000;

      this.move();
    }

    function _onBoardDragEnd(e) {
      e.preventDefault();
      dragger.removeEventListener('pointermove', onBoardDrag);
      dragger.removeEventListener('pointerup', onBoardDragEnd);
      this.dragX = 0;
      this.dragY = 0;
    }
  },
  updated() {
    this.move();
  }
}



Hooks.Dragging = {
  id: null,
  ghost: null,
  ghostX: null,
  ghostY: null,
  move() {
    this.el.style.transform = `
      translateX(${x - (PIECE_WIDTH / 2)}px) 
      translateY(${y - (PIECE_HEIGHT / 2)}px) 
      translateZ(0)`

    this.ghost.style.transform = `
        translateX(${this.ghostX}px) 
        translateY(${this.ghostY}px) 
        translateZ(0)`
  },
  get_position() {
    const col = Math.round(this.ghostX / (PIECE_WIDTH / 2))
    const row = Math.round(this.ghostY / PIECE_HEIGHT)
    return { x: col, y: row }
  },
  get_ghost_position() {
    const ghostX = roundTo(x, PIECE_WIDTH / 2) - roundTo(boardX, PIECE_WIDTH / 2) - (PIECE_WIDTH / 2)
    const ghostY = roundTo(y, PIECE_HEIGHT) - roundTo(boardY, PIECE_HEIGHT) - PIECE_HEIGHT
    return { x: ghostX, y: ghostY }
  },

  mounted() {
    this.id = this.el.firstElementChild.getAttribute('data-id')
    this.ghost = document.querySelector('#ghost')

    onKeyUp = _onKeyUp.bind(this)
    addEventListener('keyup', onKeyUp)

    onPieceDrag = _onPieceDrag.bind(this)
    onPieceDragEnd = _onPieceDragEnd.bind(this)
    dragger.addEventListener('pointermove', onPieceDrag);
    dragger.addEventListener('pointerup', onPieceDragEnd);

    this.el.style.transform = this.ghost.style.transform = `
      translateX(${x - 50}px) 
      translateY(${y - 43}px) 
      translateZ(0)`

    function _onPieceDrag(e) {
      e.preventDefault();

      const newGhostPosition = this.get_ghost_position()
      if (this.ghostX === newGhostPosition.x && this.ghostY === newGhostPosition.y) return;

      this.ghostX = newGhostPosition.x;
      this.ghostY = newGhostPosition.y;

      this.move();
      this.pushEvent('drag_move', this.get_position())

    }

    function _onPieceDragEnd(e) {
      e.preventDefault();

      this.pushEvent('drag_end', this.get_position())

      removeEventListener('keyup', onKeyUp)
      dragger.removeEventListener('pointermove', onPieceDrag);
      dragger.removeEventListener('pointerup', onPieceDragEnd);
    }

    function _onKeyUp(e) {
      if (e.keyCode === 32) {
        this.pushEvent('rotate', { piece: this.id, reverse: e.shiftKey })
        this.pushEvent('drag_move', this.get_position())
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


