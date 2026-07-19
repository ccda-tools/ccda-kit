# Security Policy

## Reporting Security Issues

Please do not open a public GitHub issue for security-sensitive reports.

Until a dedicated security contact is published, contact the repository owner privately through GitHub.

## Protected Health Information

This project is intended for parsing C-CDA test data and application-owned documents. Contributors must not commit:

- Real patient data.
- Protected health information.
- Production clinical documents.
- Credentials, tokens, keys, or certificates.

## Scope

Security reports may include:

- Unsafe XML parsing behavior.
- Excessive memory use or denial-of-service risks from large documents.
- Unsafe media extraction behavior.
- Path traversal or cache write issues.
- Accidental exposure of document contents.

## Disclaimer

This library parses C-CDA XML but does not validate clinical correctness or guarantee regulatory compliance.
