use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;

my Cro::Service $http = Cro::HTTP::Server.new(
    http => '1.1',
    host => %*ENV<CRO_WEBSITE_HOST> ||
        die("Missing CRO_WEBSITE_HOST in environment"),
    port => %*ENV<CRO_WEBSITE_PORT> ||
        die("Missing CRO_WEBSITE_PORT in environment"),
    application => routes(),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);
$http.start;
say "Listening at http://%*ENV<CRO_WEBSITE_HOST>:%*ENV<CRO_WEBSITE_PORT>";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
