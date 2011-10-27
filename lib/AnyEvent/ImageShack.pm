package AnyEvent::ImageShack;

use strict;
use AnyEvent::HTTP;
use HTTP::Request::Common 'POST';
use base 'Exporter';
our $VERSION = '0.02';

our @EXPORT = qw(image_host);

sub image_host {
	my $file = shift;
	my $cb   = pop;
	my $url = '';
	if ($file =~ /http/) {
		$url  = $file;
		$file = undef;
	}
	my $opt = ref $_[0] ? $_[0] : { @_ };
	
	$AnyEvent::HTTP::USERAGENT      = $opt->{'user_agent'} || 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.205 Safari/534.16';
	$AnyEvent::HTTP::MAX_PER_HOST ||= $opt->{'max_per_host'};
	$AnyEvent::HTTP::ACTIVE       ||= $opt->{'active'      };
	
	
	my $p = POST
		'http://post.imageshack.us/',
		Content_Type => 'multipart/form-data; boundary=---------------------------2561254751908746572894418409',
		Referer      => 'http://imageshack.us',
		Host         => 'post.imageshack.us',
		Accept       => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
		DNT          => 1,
		Content      => [
			uploadtype    => 'on',
			fileupload    => $file ? [ $file ] : [ '' ],
			url           => $url,
			email         => '',
			MAX_FILE_SIZE => 13145728,
			refer         => '',
			brand         => '',
			optimage      => 'resample',
			optsize       => 'resample',
			rembar        => 0,
		]
	;
	
	http_post 
		$p->uri,
		(join '', map {
			s{name="fileupload"}{name="fileupload"; filename=""
Content-Type: application/octet-stream} if $url;
			$_;
		} $p->content),
		recurse => 0,
		headers => {
			map {
				$_ => $p->header($_)
			} $p->header_field_names
			
		},
		sub {
			$cb->(map { s{.+&l=(\w*)/(.+)$}{http://$1.imageshack.us/$1/$2}; $_ } $_[1]->{'location'});
		}
	;
}


=head1 NAME

AnyEvent::ImageShack - simple non-blocking client for image hosting ImageShack.us

=head1 VERSION

0.02

=head1 SYNOPSIS

   use AnyEvent::ImageShack;
   
   my $c = AnyEvent->condvar;
   image_host('url/or/path/to/image.png', sub { warn shift; $c->send });
   $c->recv;

=head1 METHODS

=over 4

=item image_host $image, option => value, ..., $callback

Host image C<$image> to ImageShack.us

=back

=head1 OPTIONS

=over 4

=item user_agent - UserAgent string

=item active - number of active connections for L<AnyEvent::HTTP>

=item max_per_host - maximum connections per one host for L<AnyEvent::HTTP>

=back

=head1 SUPPORT

=over 4

=item * Repository

L<http://github.com/konstantinov/AnyEvent-ImageShack>

=back

=head1 SEE ALSO

L<AnyEvent>, L<AnyEvent::HTTP>

=head1 COPYRIGHT & LICENSE

Copyright 2010-2011 Dmitry Konstantinov. All right reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.