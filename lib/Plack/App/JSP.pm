package Plack::App::JSP;
# ABSTRACT: Javascript PSGI apps via JSP

use strict;
use parent qw(Plack::Component);
use Plack::Util::Accessor qw(js ctx);
use JSP;

sub prepare_app {
    my $self = shift;
    $self->ctx( JSP->stock_context );
}

sub call {
    my ( $self, $env ) = @_;
    my $res = $self->ctx->eval( $self->js );
    $res->[2] = [ map Encode::encode( 'utf8', $_ ), @{ $res->[2] } ]
      if ref $res->[2] eq 'ARRAY';
    return $res;
}

1;

__END__

=head1 SYNOPSIS

 # app.psgi - looks pretty normal
 use Plack::App::JSP;
 Plack::App::JSP->new( js => q{
   [ 200, [ 'Content-type', 'text/html' ], [ 'Hello, World!' ] ] 
 });

 # app.psgi - hello Javascript!
 Plack::App::JSP->new( js => q{
    function respond(body) {
        return [ 200, [ 'Content-type', 'text/html' ], [ body ] ]
    }
    
    respond("Five factorial is " + 
        (function(x) {
          if ( x<2 ) return x;
          return x * arguments.callee(x - 1);
        })(5)
    );
 });

=cut