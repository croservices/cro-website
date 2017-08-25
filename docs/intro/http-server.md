# Writing HTTP Server

It is quite easy to write up a server. Any server will be based on
`Cro::HTTP::Server` class, so we need to import it:

```
use Cro::HTTP::Server;
```

Server basically have to serve requests, so it should get requests(as
`Cro::HTTP::Request` instance) and emit responses(as
`Cro::HTTP::Resposne` instance).

User can write a transformer by hands, but it is easier to use a
`Router` abstraction.

```
use Cro::HTTP::Router;
```

With these two parts we can start out our server. `Cro::HTTP::Router`
provides `route` routine that looks like your favorite DSL for serving
requests, here is the simple example:

```
my $application = route {
    get -> {
        content 'text/html', 'Hello World!';
    }
}
```

Routines like `get`, `post`, `delete` indicate needed HTTP method,
while signature part represents the relative URL. THe absence of
arguments counts as `/`. Let's see some more examples:

```
my $application = route {
    get -> {
        content 'text/html', 'Home';
    }
    post -> 'poster' {
        content 'text/html', 'Post request to /poster page';
    }
    get -> 'articles', $author, $name {
        # Returns an article for `/articles/anonymous/first_post` URL
    }
}
```

Application created with `route` can be easily used with
`Cro::HTTP::Server` as:

```
# Creating a server...
my Cro::Service $service = Cro::HTTP::Server.new(
    :host('localhost'), :port(2314), :$application
);
# Running it
$service.start;
# Add up a react block to keep running until Ctrl-C signal
react whenever signal(SIGINT) {
    $hello-service.stop;
    exit;
}

```

And the application is up and running, so it's time to improve it: add
more logic and use other features. See `Cro::HTTP::Router` and
`Cro::HTTP::Server` for further reading.
