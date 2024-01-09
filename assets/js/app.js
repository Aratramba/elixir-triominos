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
    drag(elements) {
        const Hook = this;
        console.log('init drag')

        let activePiece = null;
        let offsetX, offsetY;

        const dragger = document.getElementById('dragger')

        dragger.addEventListener('pointermove', onDrag.bind(this), false);
        dragger.addEventListener('pointerup', onDragEnd.bind(this), false);
        addEventListener('keyup', onKeyUp.bind(this), false)


        function onDragStart(e) {
            e.preventDefault();
            const piece = e.target.closest('.piece')
            dragger.classList.remove('pointer-events-none');

            const clone = piece.cloneNode(true);
            clone.removeAttribute('id')
            dragger.appendChild(clone);

            const rect = piece.getBoundingClientRect();
            const x = e.clientX - e.offsetX;
            const y = e.clientY - e.offsetY;

            this.offsetX = e.offsetX;
            this.offsetY = e.offsetY;

            this.activePiece = clone;
            this.activePiece.style.transform = `translateX(${x}px) translateY(${y}px) translateZ(0)`
        }

        function onDrag(e) {
            if (!this.activePiece) return;
            e.preventDefault();
            const x = e.clientX - this.offsetX;
            const y = e.clientY - this.offsetY;
            this.activePiece.style.transform = `translateX(${x}px) translateY(${y}px) translateZ(0)`
        }

        function onDragEnd(e) {
            e.preventDefault();
            const dragger = document.getElementById('dragger')
            dragger.removeChild(this.activePiece)

            const id = this.activePiece.getAttribute('phx-value-piece')
            Hook.pushEvent('place', { piece: id })

            this.activePiece = null;
            this.offsetX = null;
            this.offsetY = null;
            dragger.classList.add('pointer-events-none');
            dragger.removeEventListener('pointermove', onDrag, false);
            dragger.removeEventListener('pointerup', onDragEnd, false);

        }

        elements.forEach(element => {
            element.addEventListener('pointerdown', onDragStart.bind(this), false);
        })

        function onKeyUp(e) {
            // space
            if (e.keyCode === 32) {
                const id = this.activePiece.getAttribute('phx-value-piece')
                Hook.pushEvent('rotate', { piece: id })
            }
        }

    },
    mounted() {
        const pieces = this.el.querySelectorAll('.piece')
        this.drag(pieces)
    },
    updated(e) {
        const pieces = this.el.querySelectorAll('.piece')
        console.log('updated', e)
    }
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


