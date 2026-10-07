// Oil Timer for the desktop (Mac / Windows): the web timer in a transparent,
// frameless window that floats above other windows. Opened from the web page
// through the oiltimer:// link, or on its own.
const { app, BrowserWindow, ipcMain, screen } = require('electron');
const path = require('path');

const SITE = 'https://akechany0122-lang.github.io/oil-timer/';
let win = null, query = '';

const takeLink = url => { try { query = new URL(url).search.slice(1); } catch (e) {} };
const linkIn = argv => argv.find(a => a.startsWith('oiltimer://'));

if (!app.requestSingleInstanceLock()) app.quit();
app.on('second-instance', (e, argv) => {
  const u = linkIn(argv); if (u) takeLink(u);
  if (win) { load(); win.show(); win.focus(); }
});
app.on('open-url', (e, url) => {          // macOS
  e.preventDefault(); takeLink(url);
  if (win) { load(); win.show(); win.focus(); }
});
if (process.defaultApp && process.argv[1]) app.setAsDefaultProtocolClient('oiltimer', process.execPath, [path.resolve(process.argv[1])]);
else app.setAsDefaultProtocolClient('oiltimer');
{ const u = linkIn(process.argv); if (u) takeLink(u); }

// the published page (always the latest); the copy inside the app when offline
function load() {
  const search = 'desktop=1' + (query ? '&' + query : '');
  win.loadURL(SITE + '?' + search).catch(() => win.loadFile(path.join(__dirname, 'app', 'index.html'), { search }));
}

app.whenReady().then(() => {
  const wa = screen.getPrimaryDisplay().workArea, w = 280, h = 560;
  win = new BrowserWindow({
    width: w, height: h, x: wa.x + wa.width - w - 40, y: wa.y + Math.round((wa.height - h) / 2),
    transparent: true, frame: false, hasShadow: false, resizable: false, maximizable: false, fullscreenable: false,
    backgroundColor: '#00000000', alwaysOnTop: true, title: 'Oil Timer',
    webPreferences: { preload: path.join(__dirname, 'preload.js'), backgroundThrottling: false },
  });
  win.setAlwaysOnTop(true, 'floating');
  win.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  if (process.platform === 'darwin') app.dock?.hide();      // a desktop object: no Dock icon
  load();
});

// messages from the page: move the window, resize it, close
ipcMain.on('oiltimer', (e, m) => {
  if (!win || !m) return;
  if (m.type === 'move') {
    const [x, y] = win.getPosition();
    win.setPosition(Math.round(x + (m.dx || 0)), Math.round(y + (m.dy || 0)));
  } else if (m.type === 'size') {
    const b = win.getBounds(), k = m.k || 1;
    const w = Math.round(Math.min(700, Math.max(160, b.width * k))), h = Math.round(Math.min(1400, Math.max(320, b.height * k)));
    win.setBounds({ x: Math.round(b.x + (b.width - w) / 2), y: Math.round(b.y + (b.height - h) / 2), width: w, height: h });
  } else if (m.type === 'close') app.quit();
});

app.on('window-all-closed', () => app.quit());
