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
        out.append("<table>")
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


# 포털 `web/portal/src/styles/index.css`와 동일한 토큰·클래스명
LEGAL_CSS = """
    :root {
      color: #1f2937;
      background: #faf8ff;
      font-family: "Segoe UI", system-ui, sans-serif;
      line-height: 1.5;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
    }
    a {
      color: #6d28d9;
      text-decoration: none;
    }
    a:hover { text-decoration: underline; }
    .container {
      width: min(960px, 100%);
      margin: 0 auto;
      padding: 0 20px;
    }
    .site-header {
      background: #fff;
      border-bottom: 1px solid #e5e7eb;
    }
    .site-header-inner {
      display: flex;
      align-items: center;
      justify-content: space-between;
      min-height: 64px;
    }
    .logo {
      font-weight: 700;
      font-size: 1.125rem;
      color: #4c1d95;
    }
    .nav-links {
      display: flex;
      gap: 16px;
      font-size: 0.95rem;
    }
    .btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: 10px 18px;
      border-radius: 999px;
      border: none;
      font-size: 0.95rem;
      cursor: pointer;
    }
    .btn-primary {
      background: #7c3aed;
      color: #fff;
    }
    .btn-secondary {
      background: #ede9fe;
      color: #5b21b6;
    }
    .card {
      background: #fff;
      border: 1px solid #e5e7eb;
      border-radius: 16px;
      padding: 24px;
      margin: 32px 0 16px;
    }
    .muted {
      color: #6b7280;
      font-size: 0.875rem;
    }
    .site-footer {
      margin-top: 48px;
      padding: 24px 0 40px;
      border-top: 1px solid #e5e7eb;
      color: #6b7280;
      font-size: 0.875rem;
    }
    .legal-body {
      font-size: 0.875rem;
      line-height: 1.65;
    }
    .legal-body h1 {
      font-size: 1.35rem;
      margin: 0 0 12px;
      color: #312e81;
      line-height: 1.3;
    }
    .legal-body h2 {
      font-size: 1rem;
      color: #312e81;
      margin: 1.75em 0 0.6em;
    }
    .legal-body h3 {
      font-size: 0.9rem;
      margin: 1.25em 0 0.4em;
    }
    .legal-body p { margin: 0 0 0.9em; }
    .legal-body ul, .legal-body ol { margin: 0 0 1em; padding-left: 1.3em; }
    .legal-body li { margin: 0.25em 0; }
    .legal-body em { color: #4b5563; }
    .legal-body table {
      width: 100%;
      border-collapse: collapse;
      font-size: 0.8rem;
      margin: 1em 0 1.4em;
    }
    .legal-body th,
    .legal-body td {
      border-bottom: 1px solid #e5e7eb;
      padding: 10px 8px;
      text-align: left;
      vertical-align: top;
    }
    .legal-body th { color: #5b21b6; }
    .legal-actions { margin: 8px 0 0; }
"""


EN_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title}</title>
  <style>
{css}
  </style>
</head>
<body>
  <header class="site-header">
    <div class="container site-header-inner">
      <a class="logo" href="/">Today's Language</a>
      <nav class="nav-links">
        <a href="/support/login">Contact</a>
      </nav>
    </div>
  </header>
  <main class="container">
    <article class="card legal-body">
{body}
    </article>
    <p class="legal-actions">
      <a class="btn btn-secondary" href="/">Home</a>
    </p>
  </main>
  <footer class="site-footer">
    <div class="container">
      <p>Operator: seok77 · Contact: qjatjr1285@naver.com</p>
      <p>
        <a href="/legal/privacy-en.html">Privacy Policy</a>
        ·
        <a href="/legal/terms-en.html">Terms</a>
      </p>
      <p class="muted">This page was generated by <a href="https://app-privacy-policy-generator.nisrulz.com/" target="_blank" rel="noopener noreferrer">App Privacy Policy Generator</a> (reviewed and updated for Today's Language).</p>
    </div>
  </footer>
</body>
</html>
"""

KO_TEMPLATE = """<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title}</title>
  <!-- kimlawtech / 호스팅용: 시행일 2026-09-01 -->
  <style>
{css}
  </style>
</head>
<body>
  <header class="site-header">
    <div class="container site-header-inner">
      <a class="logo" href="/">Today's Language</a>
      <nav class="nav-links">
        <a href="/support/login">문의하기</a>
      </nav>
    </div>
  </header>
  <main class="container">
    <article class="card legal-body">
{body}
    </article>
    <p class="legal-actions">
      <a class="btn btn-secondary" href="/">홈으로</a>
    </p>
  </main>
  <footer class="site-footer">
    <div class="container">
      <p>운영: seok77 · 문의: qjatjr1285@naver.com</p>
      <p>
        <a href="/legal/privacy-ko.html">개인정보 처리방침</a>
        ·
        <a href="/legal/terms-ko.html">이용약관</a>
      </p>
      <p class="muted">본 문서는 Today's Language 한국어 초안입니다. 법률 자문이 아니며 출시 전 검토가 필요합니다. 출처: <a href="https://github.com/kimlawtech/korean-privacy-terms" target="_blank" rel="noopener noreferrer">kimlawtech/korean-privacy-terms</a></p>
    </div>
  </footer>
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
        html_out = (
            EN_TEMPLATE.replace("{title}", title)
            .replace("{css}", LEGAL_CSS)
            .replace("{body}", body)
        )
        (base / name.replace(".md", ".html")).write_text(html_out, encoding="utf-8", newline="\n")
        print(f"wrote {name.replace('.md', '.html')}")

    for name, title in [
        ("privacy-ko.md", "개인정보 처리방침 — Today's Language"),
        ("terms-ko.md", "서비스 이용약관 — Today's Language"),
    ]:
        body = md_to_body_ko(base / name)
        html_out = (
            KO_TEMPLATE.replace("{title}", title)
            .replace("{css}", LEGAL_CSS)
            .replace("{body}", body)
        )
        (base / name.replace(".md", ".html")).write_text(html_out, encoding="utf-8", newline="\n")
        print(f"wrote {name.replace('.md', '.html')}")


if __name__ == "__main__":
    main()
