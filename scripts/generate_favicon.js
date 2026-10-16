const fs = require('fs');
const zlib = require('zlib');
const path = require('path');

function createPng(width, height, pixelFn) {
  const rowSize = width * 4;
  const rawData = Buffer.alloc(height * (rowSize + 1));

  for (let y = 0; y < height; y++) {
    const rowOffset = y * (rowSize + 1);
    rawData[rowOffset] = 0; // Filter type: None
    for (let x = 0; x < width; x++) {
      const pxOffset = rowOffset + 1 + x * 4;
      const [r, g, b, a] = pixelFn(x / width, y / height, x, y);
      rawData[pxOffset] = r;
      rawData[pxOffset + 1] = g;
      rawData[pxOffset + 2] = b;
      rawData[pxOffset + 3] = a;
    }
  }

  const deflated = zlib.deflateSync(rawData);

  function createChunk(type, data) {
    const len = Buffer.alloc(4);
    len.writeUInt32BE(data.length, 0);
    const typeBuf = Buffer.from(type, 'ascii');
    const crcBuf = Buffer.alloc(4);
    
    // CRC-32 over type + data
    const crcTable = [];
    for (let n = 0; n < 256; n++) {
      let c = n;
      for (let k = 0; k < 8; k++) {
        c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
      }
      crcTable[n] = c;
    }
    let crc = 0xffffffff;
    for (let i = 0; i < typeBuf.length; i++) {
      crc = crcTable[(crc ^ typeBuf[i]) & 0xff] ^ (crc >>> 8);
    }
    for (let i = 0; i < data.length; i++) {
      crc = crcTable[(crc ^ data[i]) & 0xff] ^ (crc >>> 8);
    }
    crc = (crc ^ 0xffffffff) >>> 0;
    crcBuf.writeUInt32BE(crc, 0);

    return Buffer.concat([len, typeBuf, data, crcBuf]);
  }

  const signature = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // 8 bits per channel
  ihdr[9] = 6; // RGBA
  ihdr[10] = 0; // Compression
  ihdr[11] = 0; // Filter
  ihdr[12] = 0; // Interlace

  return Buffer.concat([
    signature,
    createChunk('IHDR', ihdr),
    createChunk('IDAT', deflated),
    createChunk('IEND', Buffer.alloc(0))
  ]);
}

// Point in polygon test
function pointInPoly(x, y, poly) {
  let inside = false;
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const xi = poly[i][0], yi = poly[i][1];
    const xj = poly[j][0], yj = poly[j][1];
    const intersect = ((yi > y) !== (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

// Distance to rounded rectangle
function roundedRectDist(x, y, left, top, right, bottom, r) {
  const cx = Math.max(left + r, Math.min(x, right - r));
  const cy = Math.max(top + r, Math.min(y, bottom - r));
  const dx = x - cx;
  const dy = y - cy;
  return Math.sqrt(dx * dx + dy * dy) - r;
}

// Lightning bolt normalized coordinates (0..1)
const boltNorm = [
  [0.56, 0.20],
  [0.34, 0.52],
  [0.48, 0.52],
  [0.42, 0.80],
  [0.68, 0.46],
  [0.52, 0.46]
];

function makeIcon(size, isFavicon = false) {
  const boltPoly = boltNorm.map(([nx, ny]) => [nx * size, ny * size]);

  // Background: Neo Dark #141518 (solid black-grey)
  const bgR = 20, bgG = 21, bgB = 24;
  // Foreground: Neo Lime #C5F536 (electric neon lime)
  const fgR = 197, fgG = 245, fgB = 54;

  const pad = size * 0.08;
  const radius = size * 0.24;
  const left = pad, top = pad, right = size - pad, bottom = size - pad;

  // 4x anti-aliasing sub-pixel offsets
  const subOffsets = [
    [0.25, 0.25],
    [0.75, 0.25],
    [0.25, 0.75],
    [0.75, 0.75],
  ];

  return createPng(size, size, (u, v, px, py) => {
    if (isFavicon) {
      const d = roundedRectDist(px, py, left, top, right, bottom, radius);
      if (d > 0.5) return [0, 0, 0, 0];

      let hits = 0;
      for (const [ox, oy] of subOffsets) {
        if (pointInPoly(px + ox, py + oy, boltPoly)) hits++;
      }
      const ratio = hits / 4;
      const r = Math.round(bgR + (fgR - bgR) * ratio);
      const g = Math.round(bgG + (fgG - bgG) * ratio);
      const b = Math.round(bgB + (fgB - bgB) * ratio);
      const alpha = d <= -0.5 ? 255 : Math.round((0.5 - d) * 255);
      return [r, g, b, alpha];
    }

    // 100% full-bleed solid square for Apple Touch Icon & PWA (NO transparent pixels anywhere)
    let hits = 0;
    for (const [ox, oy] of subOffsets) {
      if (pointInPoly(px + ox, py + oy, boltPoly)) hits++;
    }
    const ratio = hits / 4;
    const r = Math.round(bgR + (fgR - bgR) * ratio);
    const g = Math.round(bgG + (fgG - bgG) * ratio);
    const b = Math.round(bgB + (fgB - bgB) * ratio);
    return [r, g, b, 255]; // Always solid opaque
  });
}

const rootDir = path.resolve(__dirname, '..');
const webDir = path.join(rootDir, 'web');
const iconsDir = path.join(webDir, 'icons');

if (!fs.existsSync(iconsDir)) fs.mkdirSync(iconsDir, { recursive: true });

// 1. Favicon (64x64 with soft squircle)
fs.writeFileSync(path.join(webDir, 'favicon.png'), makeIcon(64, true));
console.log('✓ Generated web/favicon.png');

// 2. Official Apple Touch Icon (180x180 full-bleed solid square)
fs.writeFileSync(path.join(iconsDir, 'apple-touch-icon.png'), makeIcon(180, false));
console.log('✓ Generated web/icons/apple-touch-icon.png (180x180 solid)');

// 3. PWA Icons (192x192 & 512x512 full-bleed solid square)
fs.writeFileSync(path.join(iconsDir, 'Icon-192.png'), makeIcon(192, false));
console.log('✓ Generated web/icons/Icon-192.png');

fs.writeFileSync(path.join(iconsDir, 'Icon-512.png'), makeIcon(512, false));
console.log('✓ Generated web/icons/Icon-512.png');

fs.writeFileSync(path.join(iconsDir, 'Icon-maskable-192.png'), makeIcon(192, false));
console.log('✓ Generated web/icons/Icon-maskable-192.png');

fs.writeFileSync(path.join(iconsDir, 'Icon-maskable-512.png'), makeIcon(512, false));
console.log('✓ Generated web/icons/Icon-maskable-512.png');

// 4. Android launcher icons
const mipmapDirs = [
  { dir: 'mipmap-mdpi', size: 48 },
  { dir: 'mipmap-hdpi', size: 72 },
  { dir: 'mipmap-xhdpi', size: 96 },
  { dir: 'mipmap-xxhdpi', size: 144 },
  { dir: 'mipmap-xxxhdpi', size: 192 },
];

for (const { dir, size } of mipmapDirs) {
  const targetDir = path.join(rootDir, 'android', 'app', 'src', 'main', 'res', dir);
  if (fs.existsSync(targetDir)) {
    fs.writeFileSync(path.join(targetDir, 'ic_launcher.png'), makeIcon(size, false));
    console.log(`✓ Generated android ${dir}/ic_launcher.png (${size}x${size})`);
  }
}

console.log('⚡ All icons successfully generated with full-bleed solid styling!');
