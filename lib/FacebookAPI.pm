package FacebookAPI;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='0.01';
use 5.008001;

__PACKAGE__->load_plugin(qw/DBI/);

# initialize database
use DBI;
sub setup_schema {
    my $self = shift;
    my $dbh = $self->dbh();
    my $driver_name = $dbh->{Driver}->{Name};
    my $fname = lc("sql/${driver_name}.sql");
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    my $source = do { local $/; <$fh> };
    for my $stmt (split /;/, $source) {
        next unless $stmt =~ /\S/;
        $dbh->do($stmt) or die $dbh->errstr();
    }
}

use Facebook::Graph;
sub fb {
    my $self = shift;
    if ( !defined $self->{fb} ) {
        my $conf = $self->config->{'Facebook::Graph'}
            or die "missing configuration for 'Facebook::Graph'";
        my $fb = Facebook::Graph->new(
            postback    => $conf->{postback},
            app_id      => $conf->{app_id},
            secret      => $conf->{secret},
        );
        $self->{fb} = $fb;
    }
    return $self->{fb};
}

1;
