# Optional block registry prototype (compatibility)

The owner selected simple site-owned module dispatch on 2026-11-17. Prefer
`Document.new(..., component_module: Blocks)` as described in the README; sites
do not share block classes or maintain a common block catalogue. This optional
prototype remains only to preserve the already-published `block_registry:` API.

`DastDocument::BlockRegistry` is an explicit, host-owned mapping from CMS block
keys and supported aliases to renderer factories. It is a foundation for
`rwr-97q`, not a universal renderer or host migration.

A registry never constantizes a CMS-provided key. A block is renderable only if
the host registered its key or one of its aliases.

```ruby
registry = DastDocument::BlockRegistry.new(
  key: ->(block) { block.model_name&.singular || block.record_type || block.item_type ||
    block._model_api_key || block.__typename },
  unknown: ->(block) { "<p>Unknown block: #{block._model_api_key}</p>" }
)

registry.register("prose",
  aliases: %w[prose_block ProseBlock],
  layout: :reading,
  container: :block,
  validate: ->(block, _context) { block.content.present? },
  text: ->(block) { block.content.to_s },
  renderer: ->(block, context) { context.render(ProseComponent.new(text: block.content)) })

registry.register("banner",
  aliases: %w[banner_block BannerBlock],
  layout: :wide,
  container: :shell,
  renderer: ->(block, context) { context.render(BannerComponent.new(block: block)) })
```

Pass it to the document when the host is ready:

```ruby
DastDocument::Document.new(dast, view_context: view_context, block_registry: registry).walk
```

Without `block_registry:`, the existing component-module path is unchanged.
Missing block references keep the existing document diagnostic. `block` and
`inlineBlock` nodes both resolve through the registry; ordering and repeated
references remain the caller's document order.

## Entry contract

| Field | Meaning |
|---|---|
| key / aliases | Explicit CMS discriminators. Duplicate or conflicting registration fails before rendering. |
| renderer | Callable `(block, context)`, usually a host ViewComponent/partial adapter. No implicit constant lookup. |
| validate | Optional callable `(block, context)`; false/nil raises `InvalidBlock` before the renderer runs. |
| text | Optional callable `(block)` for host text extraction/indexing. Unknown blocks return `nil`. |
| layout | Advisory role: `:reading`, `:wide` or `:section`. |
| container | Advisory ownership: `:block` (renderer owns its container/gutters) or `:shell` (host shell owns them). |

`unknown:` must be chosen by the host: `:omit`, `:raise`, or a callable that
receives the block. The registry does not silently pick a diagnostic policy.

## Presentation boundary

The registry returns only block markup. The host owns the page shell, container
widths, gutters and visual composition; `layout`/`container` are metadata, not an
automatic wrapper. Do not add a second container around a block that owns one.

Semantic token roles are host CSS, not package selectors. A compatible theme can
define its own values for roles such as:

```text
brand, surface, ink, muted, link, focus
font-body, font-heading
container-reading, container-site
radius-control
```

No shared components, CSS, token adapter or two-theme visual baseline are
implemented by this foundation. Choosing a reading column, a 1920px site
container, typography and responsive composition remains host-owned.

## Host adoption is separate

The current host paths still use their existing dispatchers and behavior. This
prototype does not change BIC, Canada, CBNS or Afnan, and no CMS content was
mutated. A host adapter must preserve its existing alias priority, unknown
policy, constructor arguments, footnotes, gallery numbering, missing-media
behavior and container ownership before switching.

The owner waived hostile-input/trust-boundary work on 2026-11-13 (`rwr-q88`);
this registry does not sanitize Markdown, HTML or embed URLs and is not an XSS
certification. Reopen that policy if input becomes untrusted.

## Verification

The `dast_document` suite covers aliases, factories, validators, text extraction,
layout/container metadata, explicit unknown policies, registration conflicts,
document order, repeated and inline blocks, and missing-block diagnostics.

On 2026-11-13, Ruby 4.0.9: **14 tests / 57 assertions**, zero failures/errors/
skips; StandardRB passes. The checkout's older test fixture was aligned with the
existing `component_name` and view-context API; no application behavior changed.
