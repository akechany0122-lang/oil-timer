// The page talks to its desktop host the same way as in the macOS (WKWebView) app.
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('webkit', {
  messageHandlers: { oiltimer: { postMessage: msg => ipcRenderer.send('oiltimer', msg) } },
});
