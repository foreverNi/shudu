from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "design-review" / "achievements-page-prototype.png"
MEDIA = ROOT / "harmony" / "SudokuHarmony" / "entry" / "src" / "main" / "resources" / "base" / "media"

S = 2.2
W, H = int(430 * S), int(932 * S)


def sc(v):
    return int(round(v * S))


def font(size, bold=False):
    candidates = [
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/System/Library/Fonts/STHeiti Medium.ttc" if bold else "/System/Library/Fonts/STHeiti Light.ttc",
        "/Library/Fonts/Arial Unicode.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, sc(size))
        except OSError:
            continue
    return ImageFont.load_default()


F = {
    "title": font(40, True),
    "subtitle": font(15),
    "card_title": font(19, True),
    "body": font(14),
    "small": font(11),
    "tiny": font(10),
    "metric": font(22, True),
    "row_title": font(14, True),
}

C = {
    "primary": "#061B46",
    "secondary": "#74849D",
    "light": "#A9B5C5",
    "blue": "#1F7CFF",
    "blue2": "#74A6FF",
    "green": "#3BAE5B",
    "card": "#FFFFFF",
    "icon_bg": "#EEF5FF",
    "bar_bg": "#EEF3FA",
    "page_top": "#FFFFFF",
    "page_mid": "#F7FAFF",
    "page_bottom": "#F3F8FF",
    "divider": "#DFE6F0",
}


def rounded(draw, box, radius, fill):
    draw.rounded_rectangle(tuple(sc(x) for x in box), radius=sc(radius), fill=fill)


def shadowed_card(base, box, radius=22, shadow_radius=22, shadow_offset=9):
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle(tuple(sc(x) for x in box), radius=sc(radius), fill=(20, 57, 101, 28))
    shadow = shadow.filter(ImageFilter.GaussianBlur(sc(shadow_radius)))
    base.alpha_composite(shadow, (0, sc(shadow_offset)))
    draw = ImageDraw.Draw(base)
    rounded(draw, box, radius, C["card"])


def paste_icon(base, name, xy, size, opacity=255):
    src = Image.open(MEDIA / name).convert("RGBA")
    src = src.resize((sc(size), sc(size)), Image.LANCZOS)
    if opacity < 255:
        alpha = src.getchannel("A").point(lambda p: int(p * opacity / 255))
        src.putalpha(alpha)
    base.alpha_composite(src, (sc(xy[0]), sc(xy[1])))


def draw_text(draw, xy, text, size_name, color, anchor=None, align="left"):
    draw.text((sc(xy[0]), sc(xy[1])), text, font=F[size_name], fill=color, anchor=anchor, align=align)


def gradient_bg():
    img = Image.new("RGBA", (W, H))
    px = img.load()
    stops = [(0.0, C["page_top"]), (0.55, C["page_mid"]), (1.0, C["page_bottom"])]
    rgb = [tuple(int(c[i:i + 2], 16) for i in (1, 3, 5)) for _, c in stops]
    for y in range(H):
        t = y / (H - 1)
        if t < stops[1][0]:
            local = t / stops[1][0]
            a, b = rgb[0], rgb[1]
        else:
            local = (t - stops[1][0]) / (1 - stops[1][0])
            a, b = rgb[1], rgb[2]
        color = tuple(int(a[i] + (b[i] - a[i]) * local) for i in range(3)) + (255,)
        for x in range(W):
            px[x, y] = color
    return img


def icon_circle(draw, cx, cy, fill=C["icon_bg"]):
    draw.ellipse((sc(cx - 17), sc(cy - 17), sc(cx + 17), sc(cy + 17)), fill=fill)


def progress_bar(draw, x, y, w, pct, color):
    rounded(draw, (x, y, x + w, y + 7), 4, C["bar_bg"])
    rounded(draw, (x, y, x + w * pct, y + 7), 4, color)


img = gradient_bg()
draw = ImageDraw.Draw(img)

# Status bar and camera area, matching the referenced Harmony screenshot crop.
draw_text(draw, (20, 25), "11:22", "body", "#20242A")
draw.ellipse((sc(197), sc(15), sc(233), sc(51)), fill="#050505")
draw.ellipse((sc(211), sc(27), sc(219), sc(35)), fill="#08274F")
draw_text(draw, (333, 25), "<:>  •••  100", "small", "#2C2F36")

# Header.
title = Image.open(MEDIA / "title_sudoku.png").convert("RGBA")
title = title.resize((sc(116), sc(45)), Image.LANCZOS)
img.alpha_composite(title, (sc(40), sc(62)))
draw_text(draw, (31, 124), "记录每一次突破与坚持", "subtitle", C["secondary"])
shadowed_card(img, (331, 45, 396, 110), radius=33, shadow_radius=18, shadow_offset=7)
draw_text(draw, (363, 66), "•••", "card_title", C["primary"], anchor="ma")

# Overview card.
shadowed_card(img, (25, 177, 405, 275))
paste_icon(img, "icon_trophy.png", (45, 200), 46)
draw_text(draw, (105, 202), "2 / 7", "metric", C["primary"])
draw_text(draw, (106, 235), "已解锁成就", "small", C["secondary"])
draw.line((sc(202), sc(197), sc(202), sc(255)), fill=C["divider"], width=sc(1))
icon_circle(draw, 236, 222)
draw_text(draw, (236, 216), "27%", "body", C["blue"], anchor="mm")
draw_text(draw, (264, 204), "下一目标", "small", C["secondary"])
draw_text(draw, (264, 228), "完成10局", "body", C["primary"])

# Key challenge card.
shadowed_card(img, (25, 294, 405, 589))
draw_text(draw, (48, 318), "关键成就", "card_title", C["primary"])
draw_text(draw, (48, 348), "难度突破与限时挑战", "small", C["secondary"])

rows = [
    ("首胜中等", "首次挑战中难度成功", "已完成", 1.0, C["blue"], "已"),
    ("首胜困难", "首次挑战困难难度成功", "未解锁", 0.0, C["light"], "锁"),
    ("十分钟中等", "中难度完成时间10分钟内", "08:48", 1.0, C["green"], "快"),
    ("十五分钟困难", "困难难度完成时间15分钟内", "未解锁", 0.0, C["light"], "锁"),
]

y = 375
for i, (name, desc, status, pct, color, mark) in enumerate(rows):
    shaded = i % 2 == 0
    if shaded:
        rounded(draw, (45, y - 10, 385, y + 49), 12, "#F8FBFF")
    icon_circle(draw, 65, y + 16, "#EEF5FF" if pct else "#F4F7FB")
    draw_text(draw, (65, y + 16), mark, "small", color, anchor="mm")
    draw_text(draw, (91, y - 1), name, "row_title", C["primary"])
    draw_text(draw, (91, y + 22), desc, "tiny", C["secondary"])
    draw_text(draw, (355, y + 7), status, "small", color, anchor="ra")
    y += 56

# Progressive challenge card.
shadowed_card(img, (25, 608, 405, 825))
draw_text(draw, (48, 632), "局数阶梯挑战", "card_title", C["primary"])
draw_text(draw, (48, 662), "每完成10局解锁一个新挑战", "small", C["secondary"])

steps = [
    ("完成10局", "6/10", 0.60, C["blue"]),
    ("完成20局", "6/20", 0.30, C["blue2"]),
    ("完成30局", "6/30", 0.20, C["green"]),
]
y = 692
for name, count, pct, color in steps:
    draw_text(draw, (50, y), name, "row_title", C["primary"])
    draw_text(draw, (355, y), count, "small", C["secondary"], anchor="ra")
    progress_bar(draw, 50, y + 27, 305, pct, color)
    y += 48

# Bottom nav.
shadowed_card(img, (0, 841, 430, 932), radius=20, shadow_radius=18, shadow_offset=-8)
nav = [
    ("icon_home_gray.png", "游戏", "#8794A8", False, 90),
    ("icon_stats_gray.png", "统计", "#8794A8", False, 215),
    ("icon_trophy.png", "成就", C["blue"], True, 340),
]
for icon, label, color, active, cx in nav:
    if active:
        rounded(draw, (cx - 53, 856, cx + 53, 912), 18, "#EEF5FF")
    paste_icon(img, icon, (cx - 13, 862), 26, opacity=255 if active else 210)
    draw_text(draw, (cx, 894), label, "small", color, anchor="ma")

draw.rounded_rectangle((sc(151), sc(919), sc(279), sc(924)), radius=sc(3), fill="#DFE2E6")

img.convert("RGB").save(OUT, quality=96)
print(OUT)
