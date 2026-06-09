# Samizdat-Plugin-Email

Email hosting (postfixadmin: domains, mailboxes, aliases, vacation) for Samizdat. An **offerable** Samizdat module (hostable for customers). Extracted
from the Samizdat monorepo with history; installs as a standalone CPAN/pkg
distribution.

## Layout

    lib/Samizdat/Plugin/Email.pm        routes + the `email` helper
    lib/Samizdat/Controller/Email.pm    request handlers
    lib/Samizdat/Model/Email.pm         business logic / data access
    lib/Samizdat/resources/templates/email/   views (install to site_perl)
    lib/Samizdat/resources/locale/email/      per-module translations

Resources install under `site_perl/Samizdat/resources/...`, where the core
resolver (`$app->resource(...)`) finds them.

## Dependencies

- **Samizdat** (core) — provides `Samizdat::Model::Cache`, `pg`/`mysql`, and the
  resource resolver. Not yet on CPAN; install the core dist or put it on `PERL5LIB`.
- Mojolicious.

## Install

    perl Makefile.PL
    make && make test          # core (Samizdat) must be on PERL5LIB
    make install               # or: make install INSTALL_BASE=/path/to/prefix

Enable it in `samizdat.yml` via `extraplugins: [Email]`.
