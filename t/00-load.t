use strict;
use warnings;
use Test::More;

# Core (Samizdat) must be on @INC (PERL5LIB) — it provides Samizdat::Model::Cache.
use_ok('Samizdat::Model::Email');
use_ok('Samizdat::Model::Email::Postfix');
use_ok('Samizdat::Controller::Email');
use_ok('Samizdat::Plugin::Email');

use File::Spec;
my ($dist_lib) = grep { -d } map { File::Spec->catdir($_, 'Samizdat', 'resources') } @INC;
ok($dist_lib, 'resources dir is on @INC') or diag "no Samizdat/resources under @INC";
ok(-d File::Spec->catdir($dist_lib, 'templates', 'email'), 'email templates ship with the dist');

done_testing;
