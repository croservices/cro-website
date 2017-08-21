use Cro::HTTP::Router;

sub routes() is export {
    route {
        get -> {
            static 'static-content/index.html'
        }

        get -> 'css', *@path {
            static 'static-content/css', @path
        }

        get -> 'js', *@path {
            static 'static-content/js', @path
        }
    }
}
