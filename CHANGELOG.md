# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-12-19

### Added
- Comprehensive edge case tests for DastDocument rendering:
  - Empty documents, invalid node types, and missing data handling.
  - Text formatting with multiple marks, unknown marks, and newlines.
  - Advanced node types: blockquotes, links, unordered lists.
  - Block rendering edge cases: multiple blocks, missing components/view contexts.
  - HTML output validation via `to_html` method.

### Changed
- Bump required Ruby version from >= 3.2.2 to >= 3.4.5
- Update Nokogiri dependency from >= 1.13.4 to >= 1.18.9
- Add REXML >= 3.3.9 as runtime dependency

### Security
- Address multiple CVEs in Nokogiri (e.g., libxml2/libxslt vulnerabilities)
- Address REXML DoS vulnerabilities by requiring Ruby >= 3.4.5 or REXML >= 3.3.9

## [1.2.0] - 2024-02-22

### Added
- Support for ordered lists and horizontal rules in HTML output.
- AGENTS.md file with project information and build commands.

### Changed
- Major library rewrite to support passing blocks and custom components for enhanced rendering flexibility.
- Removed requirement for "Component" suffix in block names, simplifying component naming conventions.
- Improved newline handling in text content for more accurate HTML rendering.
- Code cleanup and refactoring for better maintainability.
- Added RuboCop configuration for improved code style and linting.

### Fixed
- Added null checks to prevent runtime errors during document processing.
- Corrected data passing in block rendering to ensure components receive accurate content.
- Minor adjustments to block rendering functionality for improved reliability.
- Fixed broken test case to maintain test suite integrity.

## [0.1.0] - 2024-01-31

### Added
- Initial release with basic HTML rendering and structured document support.

[1.3.0]: https://github.com/paradem/dast_document/releases/tag/v1.3.0
[1.2.0]: https://github.com/paradem/dast_document/releases/tag/v1.2.0
