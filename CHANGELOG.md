## [Unreleased]

- Qualify supported Ruby series on Ubuntu 24.04, refresh the development lock,
  require patched Nokogiri >= 1.19.5 and declare `ostruct` for frozen Ruby 4
  bundles. Audit locked dependencies in CI; see docs/maintenance-qualification.md.

- Prefer site-owned `component_module:` dispatch without a block catalogue.
  Resolve only direct module constants and keep malformed names diagnostic.
  The optional registry prototype remains compatible with its published API.

- Add `DastDocument::BlockRegistry`: explicit key/alias renderer factories,
  validators, text extraction, layout/container metadata and host-chosen unknown
  policies. `Document` accepts `block_registry:` and routes `inlineBlock` nodes;
  legacy dispatch and missing-block diagnostics are unchanged.

## [0.1.0] - 2024-01-31

- Initial release
