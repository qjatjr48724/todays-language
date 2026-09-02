# Today's Language Web Portal

React SPA for public site, user support inquiries, and admin replies.

## Routes

| Path | Description |
|------|-------------|
| `/` | Public landing |
| `/support/login` | User login → new inquiry |
| `/support/new` | Submit inquiry (auth required) |
| `/admin/login` | Admin login |
| `/admin/inquiries` | Admin inquiry list |

## Local dev

```bash
cp .env.example .env
npm install
npm run dev
```

## Build

```bash
npm run build
```

Output: `dist/` (used by Firebase Hosting)

## Deploy (from repo root)

```bash
firebase deploy --only hosting,functions:submitSupportInquiry,functions:listSupportInquiriesAdmin,functions:getSupportInquiryAdmin,functions:replySupportInquiryAdmin,firestore:rules,firestore:indexes
```

Or full deploy after verifying:

```bash
firebase deploy --only hosting,functions,firestore
```

Hosting URL (dev): `https://todays-language-dev.web.app`

Legal static pages: `/legal/privacy-ko.html`, `/legal/terms-ko.html`
