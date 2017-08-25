# Making HTTP request

Cro has abilities to make HTTP requests as easy as they can be, with
enough flexibility for complex solutions.

The most simple GET request can be written as

```
# Importing the client class.
use Cro::HTTP::Client;
# Doing the requests
my $resp = await Cro::HTTP::Client.get('https://www.perl6.org/');
```

Different methods represent different HTTP methods, such as `get`,
`post`, `update` and others. Every such method returns a promise that
is be kept when the response is returned. This promise is kept with
`Cro::HTTP::Response` class instance. However, body of the request is
wrapped in another promise as it may be chunked.

To keep the defaults for every request, one can create an instance of
the client:

```
my $client = Cro::HTTP::Client.new(
    headers => [
        User-agent => 'Cro'
    ]);
my $resp = await $client.get('https://www.perl6.org/');
```

By the way, yes, you can add headers just like that. Any options that
are passed on instance creation will work on every request, yet can be
overriden for a specific request.

For more details see more complete `Cro::HTTP::Client` documentation
page.
