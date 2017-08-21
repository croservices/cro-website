use Cro::HTTP::Router;
use Text::Markdown;

sub routes() is export {
    my $docs-template = slurp 'static-content/docs-template.html';

    route {
        get -> {
            static 'static-content/index.html'
        }
        get -> 'training-support' {
            static 'static-content/training-support.html'
        }
        get -> 'roadmap' {
            static 'static-content/roadmap.html'
        }

        get -> 'css', *@path {
            static 'static-content/css', @path
        }
        get -> 'js', *@path {
            static 'static-content/js', @path
        }
        get -> 'images', *@path {
            static 'static-content/images', @path
        }

        subset DocName of Str where /^<[A..Za..z0..9-]>+$/;

        get -> 'docs' {
            doc-markdown 'index.md'
        }
        get -> 'docs', DocName $page {
            doc-markdown "$page.md";
        }
        get -> 'docs', DocName $path, DocName $page {
            doc-markdown "$path/$page.md";
        }
        sub doc-markdown($path) {
            with slurp("docs/$path") -> $markdown {
                my $parsed = parse-markdown($markdown.subst(/^^'*'\s/, { " - " }, :g));
                my $html = $parsed.to_html;
                $html .= subst(/'href="' <!before 'http's?':'>/, 'href="/docs/', :g);
                content 'text/html', $docs-template.subst('<!--DOC-CONTENT-->', $html);
            }
            else {
                not-found;
            }
        }
    }
}
