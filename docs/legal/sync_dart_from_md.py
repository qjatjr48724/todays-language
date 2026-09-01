"""docs/legal/*.md(한국어) → app/mobile/lib/data/legal/*_content.dart body 동기화."""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEGAL = Path(__file__).resolve().parent
MOBILE_LEGAL = ROOT / "app" / "mobile" / "lib" / "data" / "legal"


def extract_version(md_text: str) -> str:
    match = re.search(r"\*\*시행일:\*\*\s*(\d{4}-\d{2}-\d{2})", md_text)
    if not match:
        raise ValueError("시행일을 찾을 수 없습니다.")
    return match.group(1)


def md_to_app_body(md_path: Path) -> str:
    text = md_path.read_text(encoding="utf-8")
    lines = text.splitlines()

    start = 0
    for i, line in enumerate(lines):
        if line.startswith("# Today's Language"):
            start = i
            break
    else:
        raise ValueError(f"본문 시작 제목을 찾을 수 없습니다: {md_path}")

    body_lines: list[str] = []
    for raw in lines[start:]:
        line = raw.rstrip()
        stripped = line.strip()

        if stripped == "---":
            body_lines.append("")
            continue

        if stripped.startswith(">"):
            continue

        if stripped.startswith("|"):
            if re.match(r"^\|[-| :]+\|$", stripped):
                continue
            cells = [c.strip() for c in stripped.strip("|").split("|")]
            body_lines.append(" · ".join(c for c in cells if c))
            continue

        if stripped.startswith("### "):
            body_lines.append("")
            body_lines.append(stripped[4:])
            continue

        if stripped.startswith("## "):
            body_lines.append("")
            body_lines.append(stripped[3:])
            continue

        if stripped.startswith("# "):
            body_lines.append(stripped[2:])
            continue

        processed = re.sub(r"\*\*(.+?)\*\*", r"\1", line)
        processed = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", processed)
        processed = re.sub(r"`([^`]+)`", r"\1", processed)
        body_lines.append(processed)

    body = "\n".join(body_lines)
    body = re.sub(r"\n{3,}", "\n\n", body).strip() + "\n"

    if "'''" in body:
        raise ValueError(f"본문에 ''' 가 포함되어 Dart 문자열로 변환할 수 없습니다: {md_path}")

    return body


def write_dart_file(
    dart_path: Path,
    class_name: str,
    doc_comment: str,
    version: str,
    body: str,
) -> None:
    dart_path.write_text(
        f"""{doc_comment}
class {class_name} {{
    {class_name}._();


    static const String version = '{version}';


    /// `docs/legal` 한국어 Markdown과 동기화 (`sync_dart_from_md.py`).
    static const String body = '''
{body}''';
}}
""",
        encoding="utf-8",
    )


def main() -> None:
    pairs = [
        (
            LEGAL / "privacy-ko.md",
            MOBILE_LEGAL / "privacy_policy_content.dart",
            "PrivacyPolicyContent",
            "/// 개인정보 처리방침 전문 — `docs/legal/privacy-ko.md`와 동기화.",
        ),
        (
            LEGAL / "terms-ko.md",
            MOBILE_LEGAL / "terms_of_service_content.dart",
            "TermsOfServiceContent",
            "/// 서비스 이용약관 전문 — `docs/legal/terms-ko.md`와 동기화.",
        ),
    ]

    for md_path, dart_path, class_name, doc_comment in pairs:
        md_text = md_path.read_text(encoding="utf-8")
        version = extract_version(md_text)
        body = md_to_app_body(md_path)
        write_dart_file(dart_path, class_name, doc_comment, version, body)
        print(f"wrote {dart_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
