#!/usr/bin/env python3
"""把 Assets/base64 里的图标与作者头像解码成 Asset Catalog 资源。"""
import base64
import pathlib
import sys

PAIRS = [
    ("Assets/base64/appicon.b64",
     "Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png"),
    ("Assets/base64/avatar.b64",
     "Resources/Assets.xcassets/AuthorAvatar.imageset/avatar.jpg"),
]

root = pathlib.Path(__file__).resolve().parent.parent

for src, dst in PAIRS:
    s = root / src
    d = root / dst
    if not s.exists():
        print(f"::error::缺少 {src}", file=sys.stderr)
        sys.exit(1)
    d.parent.mkdir(parents=True, exist_ok=True)
    d.write_bytes(base64.b64decode(s.read_text().strip()))
    print(f"{dst}  {d.stat().st_size} bytes")
