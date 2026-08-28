"""Regenerate legal HTML from markdown (en + ko sync helper)."""

import html as html_lib
import re
from pathlib import Path


def md_to_body_en(md_path: Path) -> str:
    """영문 nisrulz 형식(**제목** / * 목록) → HTML body."""
    text = md_path.read_text(encoding="utf-8")
    marker = "**Privacy Policy**" if "privacy" in md_path.name else "**Terms & Conditions**"
    start = text.find(marker)
    if start < 0:
        raise ValueError(f"start marker not found in {md_path}")
    text = text[start:]
    text = re.sub(r"\* \* \*[\s\S]*$", "", text).strip()
    lines = text.splitlines()
    out: list[str] = []
    in_ul = False
    title = "Privacy Policy" if "privacy" in md_path.name else "Terms & Conditions"
    out.append(f"<strong>{title}</strong>")

    i = 0
    while i < len(lines):
        line = lines[i].rstrip()
        i += 1
        if not line.strip():
            if in_ul:
                out.append("</ul>")
                in_ul = False
            out.append("<br>")
            continue

        if line.startswith("**") and line.endswith("**") and line.count("**") == 2:
            if in_ul:
                out.append("</ul>")
                in_ul = False
            out.append(f"<strong>{html_lib.escape(line.strip('*'))}</strong>")
            continue

        if line.startswith("| ") and "|" in line[2:]:
            if re.match(r"^\|[-| :]+\|$", line):
                continue
            cells = [c.strip() for c in line.strip("|").split("|")]
            if not in_ul:
                out.append("<ul>")
                in_ul = True
            joined = " — ".join(html_lib.escape(c) for c in cells if c)
            out.append(f"<li>{joined}</li>")
            continue

        if line.startswith("*   "):
            if not in_ul:
                out.append("<ul>")
                in_ul = True
            content = line[4:]
            content = inline_md(content)
            out.append(f"<li>{content}</li>")
            continue

        if in_ul:
            out.append("</ul>")
            in_ul = False
        out.append(f"<p>{inline_md(line)}</p>")

    if in_ul:
        out.append("</ul>")
    return "".join(out)


def inline_md(text: str) -> str:
    """링크·볼드만 인라인 변환 (이미 escape된 텍스트가 아닌 raw md)."""
    # 먼저 링크·볼드 자리를 보호한 뒤 escape하면 복잡하므로
    # escape 후 마크다운 패턴을 다시 살리는 방식 대신, 조각을 나눠 처리한다.
    parts: list[str] = []
    pos = 0
    pattern = re.compile(
        r"\[([^\]]+)\]\(([^)]+)\)|\*\*([^*]+)\*\*"
    )
    for m in pattern.finditer(text):
        if m.start() > pos:
            parts.append(html_lib.escape(text[pos:m.start()]))
        if m.group(1) is not None:
            label = html_lib.escape(m.group(1))
            href = html_lib.escape(m.group(2), quote=True)
            parts.append(
                f'<a href="{href}" target="_blank" rel="noopener noreferrer">{label}</a>'
            )
        else:
            parts.append(f"<strong>{html_lib.escape(m.group(3))}</strong>")
        pos = m.end()
    if pos < len(text):
        parts.append(html_lib.escape(text[pos:]))
    return "".join(parts) if parts else html_lib.escape(text)


def strip_ko_front_matter(text: str) -> str:
    """메타 헤더 제거. --- 이후(면책 한 줄 + 본문)부터 반환."""
    if "\n---\n" in text:
        return text.split("\n---\n", 1)[1].strip()
    lines = text.splitlines()
    for i, line in enumerate(lines):
        if line.startswith("# Today's Language"):
            return "\n".join(lines[i:])
    return text


def md_to_body_ko(md_path: Path) -> str:
    """한국어 표준 마크다운(# / ## / 목록 / 표) → HTML body."""
    raw = md_path.read_text(encoding="utf-8")
    text = strip_ko_front_matter(raw)
    lines = text.splitlines()
    out: list[str] = []
    in_ul = False
    in_ol = False
    in_table = False
    table_rows: list[list[str]] = []

    def close_lists() -> None:
        nonlocal in_ul, in_ol
        if in_ul:
            out.append("</ul>")
            in_ul = False
        if in_ol:
            out.append("</ol>")
            in_ol = False

    def flush_table() -> None:
        nonlocal in_table, table_rows
        if not table_rows:
            in_table = False
            return
        out.append('<table border="1" cellpadding="8" cellspacing="0" style="border-collapse:collapse;width:100%;margin:1em 0;">')
        for idx, cells in enumerate(table_rows):
            tag = "th" if idx == 0 else "td"
            out.append("<tr>")
            for c in cells:
                out.append(f"<{tag}>{inline_md(c)}</{tag}>")
            out.append("</tr>")
        out.append("</table>")
        table_rows = []
        in_table = False

    i = 0
    while i < len(lines):
        line = lines[i].rstrip()
        i += 1

        # 표 구분선
        if re.match(r"^\|[-| :]+\|$", line.strip()):
            continue

        # 표 행
        if line.strip().startswith("|") and "|" in line.strip()[1:]:
            close_lists()
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            table_rows.append(cells)
            in_table = True
            continue
        elif in_table:
            flush_table()

        if not line.strip():
            close_lists()
            continue

        # 면책 한 줄 (본문 앞 안내) — 이미 strip 후라 거의 없음
        if line.startswith("본 초안은") and "법률" in line:
            close_lists()
            out.append(f"<p><em>{html_lib.escape(line)}</em></p>")
            continue

        if line.startswith("### "):
            close_lists()
            out.append(f"<h3>{html_lib.escape(line[4:].strip())}</h3>")
            continue

        if line.startswith("## "):
            close_lists()
            out.append(f"<h2>{html_lib.escape(line[3:].strip())}</h2>")
            continue

        if line.startswith("# "):
            close_lists()
            out.append(f"<h1>{html_lib.escape(line[2:].strip())}</h1>")
            continue

        # 순서 없는 목록
        if re.match(r"^- ", line):
            if in_ol:
                out.append("</ol>")
                in_ol = False
            if not in_ul:
                out.append("<ul>")
                in_ul = True
            out.append(f"<li>{inline_md(line[2:])}</li>")
            continue

        # 순서 있는 목록 (1. 2. 또는 1) )
        ol = re.match(r"^(\d+)[.)]\s+(.*)$", line)
        if ol:
            if in_ul:
                out.append("</ul>")
                in_ul = False
            if not in_ol:
                out.append("<ol>")
                in_ol = True
            out.append(f"<li>{inline_md(ol.group(2))}</li>")
            continue

        # 들여쓴 하위 항목 (   - )
        sub = re.match(r"^\s{2,}-\s+(.*)$", line)
        if sub:
            if not in_ul and not in_ol:
                out.append("<ul>")
                in_ul = True
            out.append(f"<li>{inline_md(sub.group(1))}</li>")
            continue

        close_lists()
        out.append(f"<p>{inline_md(line)}</p>")

    if in_table:
        flush_table()
    close_lists()
    return "\n".join(out)


EN_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title}</title>
  <style>body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; padding: 1em; line-height: 1.5; max-width: 48rem; margin: 0 auto; }</style>
</head>
<body>
{body}
<hr>
<p><span>This page was generated by </span><a href="https://app-privacy-policy-generator.nisrulz.com/" target="_blank" rel="noopener noreferrer">App Privacy Policy Generator</a> (reviewed and updated for Today's Language).</p>
</body>
</html>
"""

KO_TEMPLATE = """<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title}</title>
  <!-- kimlawtech / 호스팅용: 시행일 2026-08-31 -->
  <style>
    body { font-family: 'Apple SD Gothic Neo', 'Malgun Gothic', 'Helvetica Neue', Helvetica, Arial, sans-serif; padding: 1em; line-height: 1.6; max-width: 48rem; margin: 0 auto; color: #222; }
    h1 { font-size: 1.5rem; }
    h2 { font-size: 1.2rem; margin-top: 1.75em; border-bottom: 1px solid #ddd; padding-bottom: 0.25em; }
    h3 { font-size: 1.05rem; margin-top: 1.25em; }
    table { font-size: 0.9rem; }
    th { background: #f5f5f5; text-align: left; }
    a { color: #0b57d0; }
  </style>
</head>
<body>
{body}
<hr>
<p><small>본 문서는 Today's Language 한국어 초안입니다. 법률 자문이 아니며 출시 전 검토가 필요합니다. 출처: <a href="https://github.com/kimlawtech/korean-privacy-terms" target="_blank" rel="noopener noreferrer">kimlawtech/korean-privacy-terms</a></small></p>
</body>
</html>
"""


def main() -> None:
    base = Path(__file__).parent

    for name, title in [
        ("privacy-en.md", "Privacy Policy"),
        ("terms-en.md", "Terms & Conditions"),
    ]:
        body = md_to_body_en(base / name)
        html_out = EN_TEMPLATE.replace("{title}", title).replace("{body}", body)
        (base / name.replace(".md", ".html")).write_text(html_out, encoding="utf-8", newline="\n")
        print(f"wrote {name.replace('.md', '.html')}")

    for name, title in [
        ("privacy-ko.md", "개인정보 처리방침 — Today's Language"),
        ("terms-ko.md", "서비스 이용약관 — Today's Language"),
    ]:
        body = md_to_body_ko(base / name)
        html_out = KO_TEMPLATE.replace("{title}", title).replace("{body}", body)
        (base / name.replace(".md", ".html")).write_text(html_out, encoding="utf-8", newline="\n")
        print(f"wrote {name.replace('.md', '.html')}")


if __name__ == "__main__":
    main()
