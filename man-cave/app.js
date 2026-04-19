// man-cave — single-page launcher. LocalStorage keyed by "mancave.tiles".
// Defaults to Lemonade + Gaia, never auto-removes them unless user edits.

const DEFAULTS = [
    { emoji: "🍋", name: "Lemonade",  url: "http://127.0.0.1:8000/"  },
    { emoji: "🌱", name: "Gaia",       url: "http://127.0.0.1:7860/" },
];

const STORAGE_KEY = "mancave.tiles";

function load() {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return [...DEFAULTS];
    try {
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed) && parsed.length) return parsed;
    } catch { /* fall through */ }
    return [...DEFAULTS];
}

function save(tiles) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(tiles));
}

function makeTile(t, idx, tiles) {
    const a = document.createElement("a");
    a.href = t.url;
    a.className = "tile";
    a.target = "_blank";
    a.rel = "noopener";

    const emoji = document.createElement("span");
    emoji.className = "emoji";
    emoji.textContent = t.emoji || "🪄";
    a.appendChild(emoji);

    const name = document.createElement("span");
    name.className = "name";
    name.textContent = t.name;
    a.appendChild(name);

    const url = document.createElement("span");
    url.className = "url";
    url.textContent = t.url;
    a.appendChild(url);

    const del = document.createElement("button");
    del.className = "del";
    del.title = "remove";
    del.textContent = "×";
    del.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (confirm(`remove "${t.name}"?`)) {
            const next = tiles.filter((_, i) => i !== idx);
            save(next);
            render(next);
        }
    });
    a.appendChild(del);
    return a;
}

function render(tiles) {
    const host = document.getElementById("tiles");
    host.replaceChildren(...tiles.map((t, i) => makeTile(t, i, tiles)));
}

const dlg = document.getElementById("editDlg");
document.getElementById("addBtn").addEventListener("click", () => {
    document.getElementById("fName").value = "";
    document.getElementById("fUrl").value = "";
    document.getElementById("fEmoji").value = "";
    dlg.showModal();
});
dlg.addEventListener("close", () => {
    if (dlg.returnValue !== "save") return;
    const name = document.getElementById("fName").value.trim();
    const url  = document.getElementById("fUrl").value.trim();
    const emoji = document.getElementById("fEmoji").value.trim() || "🪄";
    if (!name || !url) return;
    const tiles = load();
    tiles.push({ emoji, name, url });
    save(tiles);
    render(tiles);
});

render(load());

// Daily wallpaper. Prefer Bing's daily image. Fall back to /wallpapers/today.jpg.
(async function wallpaper() {
    const el = document.getElementById("wallpaper");
    const credit = document.getElementById("wallpaperCredit");
    try {
        const r = await fetch("https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1", { mode: "cors" });
        if (!r.ok) throw 0;
        const j = await r.json();
        const img = j.images?.[0];
        if (!img) throw 0;
        const src = `https://www.bing.com${img.urlbase}_1920x1080.jpg`;
        const pre = new Image();
        pre.onload = () => { el.style.backgroundImage = `url("${src}")`; el.classList.add("loaded"); };
        pre.src = src;
        credit.textContent = img.copyright ?? "";
    } catch {
        el.style.backgroundImage = 'url("wallpapers/today.jpg")';
        el.classList.add("loaded");
        credit.textContent = "";
    }
})();
