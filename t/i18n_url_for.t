#!/usr/bin/env perl
use lib qw(lib ../lib ../mojo/lib ../../mojo/lib);
use utf8;

use Mojo::Base -strict;

# Disable Bonjour, IPv6 and libev
BEGIN {
  $ENV{MOJO_NO_BONJOUR} = $ENV{MOJO_NO_IPV6} = 1;
  $ENV{MOJO_IOWATCHER} = 'Mojo::IOWatcher';
}

use Test::More tests => 14;

package App::I18N;
use base 'Locale::Maketext';

package App::I18N::en;
use Mojo::Base 'App::I18N';

our %Lexicon = (_AUTO => 1, hello2 => 'Hello two');

package App::I18N::ru;
use Mojo::Base 'App::I18N';

our %Lexicon = (hello => 'Привет', hello2 => 'Привет два');

package main;
use Mojolicious::Lite;

use Test::Mojo;

# I18N plugin
plugin 'I18N' => { namespace => 'App::I18N', default => 'ru', support_url_langs => [qw(ru en de)] };

get '/' => 'index';

#

my $t = Test::Mojo->new;

$t->get_ok('/')->status_is(200)
  ->content_is("ПриветПривет дваru\n/\n/?test=1\n");

$t->get_ok('/ru')->status_is(200)
  ->content_is("ПриветПривет дваru\n/ru\n/ru?test=1\n");

$t->get_ok('/en')->status_is(200)
  ->content_is("helloHello twoen\n/en\n/en?test=1\n");

$t->get_ok('/de')->status_is(200)
  ->content_is("ПриветПривет дваru\n/de\n/de?test=1\n");

$t->get_ok('/es')->status_is(404)
;

__DATA__
@@ index.html.ep
<%=l 'hello' %><%=l 'hello2' %><%= languages %>
%= url_for
%= url_for->query(test => 1)
