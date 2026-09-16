"""Contact sheets of all 366 Civitates plates for visual classification."""
import os, csv
from PIL import Image, ImageDraw, ImageFont, ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True
Image.MAX_IMAGE_PIXELS = None

SRC = 'D:/Dropbox/Research_projects/Mapping_medieval_population/Data/Labelling/full_pages/'
OUT = 'D:/tmp/sheets/'
os.makedirs(OUT, exist_ok=True)
files = sorted(f for f in os.listdir(SRC) if f.endswith('.jpg'))
box = (0.125, 0.075, 0.885, 0.875)   # plate area within the book-spread scans
TW, TH = 560, 400                      # thumbnail cell
COLS, ROWS = 3, 3
PER = COLS * ROWS
font = ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf', 22)

# thumbnails are cached so re-runs are cheap
thumbs = []
for k, f in enumerate(files):
    tp = OUT + 'thumb_%03d.jpg' % k
    if not os.path.exists(tp):
        im = Image.open(SRC + f)
        im.draft('RGB', (im.size[0] // 8, im.size[1] // 8))  # fast JPEG downscale on load
        W, H = im.size
        im = im.crop((int(box[0]*W), int(box[1]*H), int(box[2]*W), int(box[3]*H)))
        im.thumbnail((TW, TH - 30), Image.LANCZOS)
        im.save(tp, quality=80)
    thumbs.append(tp)

with open(OUT + 'sheet_index.csv', 'w', newline='', encoding='utf-8') as fh:
    w = csv.writer(fh); w.writerow(['k', 'sheet', 'file'])
    for k, f in enumerate(files):
        w.writerow([k, k // PER + 1, f])

for s in range(0, len(files), PER):
    sheet = Image.new('RGB', (COLS * TW, ROWS * TH), 'white')
    dr = ImageDraw.Draw(sheet)
    for j, k in enumerate(range(s, min(s + PER, len(files)))):
        t = Image.open(thumbs[k])
        x = (j % COLS) * TW; y = (j // COLS) * TH
        sheet.paste(t, (x + (TW - t.size[0]) // 2, y + 28))
        label = '%d  %s' % (k, files[k][:52])
        dr.rectangle((x, y, x + TW, y + 26), fill='black')
        dr.text((x + 4, y + 2), label, fill='white', font=font)
    sheet.save(OUT + 'sheet_%02d.jpg' % (s // PER + 1), quality=82)
print('sheets:', (len(files) + PER - 1) // PER)
