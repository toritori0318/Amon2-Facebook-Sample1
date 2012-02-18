package FacebookAPI::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;

get '/facebook' => sub {
    my ($c) = @_;
    $c->redirect(
        $c->fb->authorize->extend_permissions( qw(read_stream) )->uri_as_string
    );
};

get '/facebook/postback' => sub {
    my ($c) = @_;
    $c->fb->request_access_token($c->req->param('code'));
    $c->session->set('token' => $c->fb->access_token);
    $c->redirect( 'http://localhost:5000/' );
};

get '/' => sub {
    my ($c) = @_;
    my $data;
    my $token = $c->session->get('token');
    if ( $token ) { # loggedin
        $c->fb->access_token( $token );
        $data = $c->fb->fetch('me/home')->{data};
    }
    $c->render(
        'index.tt',
        {
            data => $data,
        }
    );
};

post '/account/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    $c->redirect('/');
};

1;
