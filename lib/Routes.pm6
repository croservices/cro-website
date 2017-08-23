use Cro::HTTP::Router;
use Text::Markdown;

sub routes() is export {
    my $docs-template = slurp 'static-content/docs-template.html';
    my %lookup;
    my @files = 'docs'.IO;
    while @files {
        for @files.pop.dir {
            if .d {
                @files.push($_);
            } else {
                my $module = .basename.Str.subst('-', '::', :g).subst('.md', '');
                my $link = .Str.subst('docs/', '').subst('.md', '');
                %lookup{$module} = $link
            }
        }
    }

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
        get -> 'fonts', *@path {
            static 'static-content/fonts', @path
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
                for $parsed.document.items -> $item {
                    if $item ~~ Text::Markdown::Paragraph {
                        for $item.items.kv -> $idx, $val {
                            when $val ~~ Text::Markdown::Code {
                                my $file = %lookup{$val.text.lc};
                                if $file {
                                    $item.items[$idx] = "<a href=\"$file\">$val\</a>";
                                }
                            }
                        }
                    }
                }
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
