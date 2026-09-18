# CONBUS tag lookup

Find a CONBUS tag from 000 to 999, then copy its link or show its QR code. It all runs in the browser and keeps working offline after the first visit.

Live at https://iameno9.github.io/conbus-tags/

- `index.html` is the whole app: markup, styles, a small QR encoder and the page script.
- `sw.js` keeps a copy for offline use and refreshes it in the background, so changes reach installed copies the next time they open.
- `manifest.webmanifest` and the PNG icons let it be added to a home screen.

To work on it, serve the folder with `python3 -m http.server` and open http://localhost:8000. After touching the encoder, check that every tag still scans (needs a Mac):

    swift tools/check-qr.swift
