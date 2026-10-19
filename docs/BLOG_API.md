# Blog API

JSON API for publishing blog posts from an automated pipeline. Posts created here
appear on `/blog` and `/blog/:slug` as soon as they are published, and can still be
managed in `/admin/posts`.

## Setup

Set a long random secret in the server environment:

```
BLOG_API_TOKEN=<random string, e.g. output of `openssl rand -hex 32`>
```

If `BLOG_API_TOKEN` is not set, every endpoint returns `503` (the API is off).

Every request must send:

```
Authorization: Bearer <BLOG_API_TOKEN>
Content-Type: application/json
```

## Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/posts` | List posts (newest first). Query: `published=true\|false`, `page`, `per_page` (max 100). Body text is omitted. |
| `GET` | `/api/posts/:slug` | One post, including `body`. |
| `POST` | `/api/posts` | Create a post. Returns `201`. |
| `PATCH` | `/api/posts/:slug` | Update any fields of a post. |
| `DELETE` | `/api/posts/:slug` | Delete a post. |

`:slug` also accepts the numeric post id.

## Fields

| Field | Notes |
|---|---|
| `title` | **Required.** |
| `slug` | Optional. Generated from the title if omitted (`-2`, `-3`… added on clashes). Must be unique. |
| `body` | Article text. Paragraphs separated by a blank line. Basic HTML (`<h2>`, `<a>`, `<strong>`, `<ul>`…) is allowed; scripts are stripped. |
| `excerpt` | Short summary for the blog listing. Falls back to the first paragraph. |
| `category` | One of: School Leadership, Teaching & Learning, Parents, EdTech, Operations, Summit, News (case-insensitive). |
| `cover_image` | Public image URL. |
| `author` | Defaults to "The Schools of India". |
| `published` | `true` to go live. **Defaults to `false` (draft).** |
| `published_at` | Optional ISO 8601 time. Set automatically the first time a post is published. |

Fields can be sent at the top level or wrapped as `{ "post": { ... } }`.

## Example

```bash
curl -X POST https://<your-site>/api/posts \
  -H "Authorization: Bearer $BLOG_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "How to Choose the Right CBSE School",
    "excerpt": "A practical checklist for parents.",
    "body": "First paragraph.\n\n<h2>Section</h2>\n\nSecond paragraph.",
    "category": "Parents",
    "cover_image": "https://cdn.example.com/cover.jpg",
    "published": true
  }'
```

Response (`201`):

```json
{
  "post": {
    "id": 12, "slug": "how-to-choose-the-right-cbse-school",
    "title": "How to Choose the Right CBSE School", "published": true,
    "published_at": "2026-10-19T10:00:00.000Z",
    "url": "https://<your-site>/blog/how-to-choose-the-right-cbse-school",
    "...": "..."
  }
}
```

## Errors

| Status | Meaning |
|---|---|
| `400` | Empty request body on create. |
| `401` | Missing or wrong token. |
| `404` | No post with that slug/id. |
| `422` | Validation failed — see `errors` array (e.g. missing title, taken slug, unknown category). |
| `503` | `BLOG_API_TOKEN` is not configured on the server. |
