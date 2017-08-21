use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Cro::Transform;
use Routes;

class CacheHeader does Cro::Transform {
    method consumes() { Cro::HTTP::Response }
    method produces() { Cro::HTTP::Response }
    method transformer(Supply $responses --> Supply) {
        supply {
            whenever $responses {
                .append-header('Cache-control', 'public, max-age=60');
                .emit;
            }
        }
    }
}

my Cro::Service $http = Cro::HTTP::Server.new(
    http => '1.1',
    host => %*ENV<CRO_WEBSITE_HOST> ||
        die("Missing CRO_WEBSITE_HOST in environment"),
    port => %*ENV<CRO_WEBSITE_PORT> ||
        die("Missing CRO_WEBSITE_PORT in environment"),
    application => routes(),
    after => [
        CacheHeader,
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
