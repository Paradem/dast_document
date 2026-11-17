# CI and dependency qualification

2026-11-17: `rwr-a5t` / `rwr-pvy`.

The old CI pinned Ruby 3.2.2 on `ubuntu-latest`, which advanced to a runner
without that old Ruby binary. CI now pins Ubuntu 24.04 and tests the latest patch
in each supported Ruby series: 3.2, 3.3, 3.4 and 4.0. The package's minimum Ruby
remains 3.2.2; `.standard.yml` now reflects the supported 3.2 syntax floor.

## Alert triage

All **26 open GitHub alerts** were for the checked-in development `Gemfile.lock`:
20 for Nokogiri 1.16.0, six for REXML 3.2.6. GitHub labelled them runtime, but their
actual dependency paths differ:

- **Nokogiri is a real runtime dependency.** Raise its gemspec minimum to
  **1.19.5**, the highest patched floor required by the reported advisories.
  The refreshed development lock resolves **1.19.7**.
- **REXML came through the old development RuboCop/Standard stack**, not the
  library's runtime dependencies. Updating that development stack removes REXML
  entirely rather than declaring it as a runtime dependency.
- A frozen Ruby 4 bundle exposed an undeclared `ostruct` dependency that direct,
  unbundled tests had masked. Declare it explicitly; the library handles cached
  OpenStruct trees and Ruby 4 no longer supplies it as a default gem.

Development tooling is resolved on Ruby 3.2, with macOS/Linux platforms and a
stable Bundler 4.0.23 lock. Runtime dependency changes are limited to the patched
Nokogiri floor and the required `ostruct` declaration; no renderer/block API or
consumer lock is changed by this maintenance patch.

## Reproduction

```sh
BUNDLE_FROZEN=true bundle install
bundle exec rake
bundle exec standardrb
bundle exec bundler-audit check --update
gem build dast_document.gemspec
```

`bundler-audit` is a development dependency and runs in the Ruby 3.2 CI job with
a fresh advisory database. The lock is not packaged in the gem. Refreshing it
alone would not protect consumers forced onto an old Nokogiri, hence the runtime
floor. No GitHub alert is manually dismissed or reclassified; default-branch
resolution must be verified after publication, not inferred from this document.

This is dependency/CI qualification, not an HTML-sanitization or CMS-input safety
certification. The owner-selected site-module dispatch remains unchanged.
