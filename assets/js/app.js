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

Hooks.Board = {
    mounted() {
        this.el.style.transform = 'translate(-500px, -1000px)'
    },
    updated() {
        this.el.style.transform = 'translate(-500px, -1000px)'
    }
}

Hooks.Hand = {

    /**
     * How about: 
     * on drag start we send a message to the server that makes it the current dragging item
     * from then on we can rotate?
     */


    drag(elements) {
        const Hook = this;
        console.log('init drag')

        let activePiece = null;

        const dragger = document.getElementById('dragger')

        dragger.addEventListener('pointerdown', onDragStart.bind(this), false);
        addEventListener('keyup', onKeyUp.bind(this), false)

        function onDragStart(e) {
            e.preventDefault();

            const clickedElements = document.elementsFromPoint(e.clientX, e.clientY);
            const piece = clickedElements.find(element => element.classList.contains('draggable-piece'))

            if (!piece) return;
            let boundOnPieceDragStart = onPieceDragStart.bind(this, e, piece)
            boundOnPieceDragStart();

        }

        /**
         * Piece drag logic
         */

        function onPieceDragStart(e, piece) {

            dragger.addEventListener('pointermove', onPieceDrag.bind(this), false);
            dragger.addEventListener('pointerup', onPieceDragEnd.bind(this), false);

            dragger.classList.remove('pointers-events-none');

            // const clone = document.createElement('div');
            // clone.innerHTML = piece.innerHTML
            // clone.id = piece.id;
            const clone = piece;

            dragger.appendChild(piece);

            const x = e.clientX - 50;
            const y = e.clientY - 43;

            this.offsetX = e.offsetX;
            this.offsetY = e.offsetY;

            this.activePiece = clone;
            this.activePiece.style.transform = `translateX(${x}px) translateY(${y}px) translateZ(0)`
        }

        function onPieceDrag(e) {
            if (!this.activePiece) return;
            e.preventDefault();
            const x = e.clientX - 50;
            const y = e.clientY - 43;
            this.activePiece.style.transform = `translateX(${x}px) translateY(${y}px) translateZ(0)`
        }

        function onPieceDragEnd(e) {
            if (!this.activePiece) return;

            e.preventDefault();
            const dragger = document.getElementById('dragger')
            dragger.removeChild(this.activePiece)

            const id = this.activePiece.id
            console.log(this.activePiece)
            Hook.pushEvent('place', { piece: id })

            this.activePiece = null;
            this.offsetX = null;
            this.offsetY = null;
            dragger.classList.add('pointer-events-none');
            dragger.removeEventListener('pointermove', onPieceDrag, false);
            dragger.removeEventListener('pointerup', onPieceDragEnd, false);

        }

        function onKeyUp(e) {
            // space
            if (e.keyCode === 32) {
                const id = this.activePiece.id
                Hook.pushEvent('rotate', { piece: id })

                // const pieceShape = this.activePiece.firstElementChild;
                // const rotate = getComputedStyle(pieceShape).getPropertyValue('--rotate') || 0;
                // this.activePiece.firstElementChild.style.rotate = 'var(--rotate)deg'
                // const originalItem = document.querySelector(`[phx-value-piece="${id}"]`)
                // console.log(originalItem)
                // const rotation = +this.activePiece.getAttribute('data-rotation');
                // this.activePiece.setAttribute('data-rotation', rotation + )
            }
        }

    },
    mounted() {
        const pieces = this.el.querySelectorAll('.piece')
        this.drag(pieces)
    },
    // updated(e) {
    //     console.log('updated', e)
    // },
    // handleEvent(e, payload) {
    //     console.log('handle event')
    //     console.log(e, payload)
    // }
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


