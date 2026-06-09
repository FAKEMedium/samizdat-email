use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Find;

# Install EVERYTHING under lib/ — modules AND the resources tree. EUMM's default
# PM detection only picks up .pm/.pod, so we build the PM map ourselves
# (Mojolicious-style: ship resources under lib/Samizdat/resources/).
my %pm;
find(
  sub {
    return unless -f;
    return if /\.(bak|orig|rej|swp)$/;
    my $path = $File::Find::name;
    (my $rel = $path) =~ s{^lib/}{};
    $pm{$path} = "\$(INST_LIB)/$rel";
  },
  'lib',
);

WriteMakefile(
  NAME             => 'Samizdat::Plugin::Email',
  VERSION          => '0.01',
  ABSTRACT         => 'Email hosting (postfixadmin: domains, mailboxes, aliases, vacation) for Samizdat',
  AUTHOR           => 'Hans Svensson <hans\@alipang.se>',
  LICENSE          => 'artistic_2',
  MIN_PERL_VERSION => '5.036',
  PM               => \%pm,
  PREREQ_PM        => { 'Mojolicious' => '9.0' },
  TEST_REQUIRES    => { 'Test::More' => 0 },
  META_MERGE       => {
    'meta-spec' => { version => 2 },
    prereqs     => { runtime => { requires => { 'Samizdat' => 0 } } },
    no_index    => { directory => ['lib/Samizdat/resources'] },
    resources   => { license => ['https://dev.perl.org/licenses/artistic.html'] },
  },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
  clean => { FILES => 'Samizdat-Plugin-Email-*' },
);
