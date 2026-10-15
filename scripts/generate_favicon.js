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

function makeIcon(size) {
  const pad = size * 0.08;
  const radius = size * 0.28;
  const left = pad, top = pad, right = size - pad, bottom = size - pad;

  // Lightning bolt normalized coordinates (0..1)
  const boltNorm = [
    [0.56, 0.20],
    [0.34, 0.52],
    [0.48, 0.52],
    [0.42, 0.80],
    [0.68, 0.46],
    [0.52, 0.46]
  ];
  const boltPoly = boltNorm.map(([nx, ny]) => [nx * size, ny * size]);

  return createPng(size, size, (u, v, x, y) => {
    // Check distance to rounded card
    const d = roundedRectDist(x, y, left, top, right, bottom, radius);
    if (d > 0.5) {
      return [0, 0, 0, 0]; // Transparent outside
    }

    // Inside squircle
    // Check if inside lightning bolt
    const inBolt = pointInPoly(x, y, boltPoly);
    if (inBolt) {
      // Electric Acid Lime: #C5F536 -> [197, 245, 54]
      return [197, 245, 54, 255];
    }

    // Border / Corner anti-aliasing
    const alpha = d <= -0.5 ? 255 : Math.round((0.5 - d) * 255);
    // Matte Dark: #121212 -> [18, 18, 18]
    return [18, 18, 18, alpha];
  });
}

const rootDir = path.resolve(__dirname, '..');
const webDir = path.join(rootDir, 'web');
const iconsDir = path.join(webDir, 'icons');

if (!fs.existsSync(iconsDir)) fs.mkdirSync(iconsDir, { recursive: true });

// Generate favicon (64x64)
fs.writeFileSync(path.join(webDir, 'favicon.png'), makeIcon(64));
console.log('✓ Generated web/favicon.png');

// Generate PWA icons
fs.writeFileSync(path.join(iconsDir, 'Icon-192.png'), makeIcon(192));
console.log('✓ Generated web/icons/Icon-192.png');

fs.writeFileSync(path.join(iconsDir, 'Icon-512.png'), makeIcon(512));
console.log('✓ Generated web/icons/Icon-512.png');
