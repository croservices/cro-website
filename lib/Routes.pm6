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

        sub wrap-header($h, $anchor) {
            '<h' ~ $h.level ~ '>' ~ $h.text ~
                "<a class=\"title-anchor\" name=\"$anchor\" href=\"#$anchor\">§</a>" ~
                '</h' ~ $h.level ~ '>';
        }

        sub doc-markdown($path) {
            with slurp("docs/$path") -> $markdown {
                my $parsed = parse-markdown($markdown);
                my @heading-links;
                for $parsed.document.items -> $item is rw {
                    if $item ~~ Text::Markdown::Paragraph {
                        for $item.items.kv -> $idx, $val {
                            when $val ~~ Text::Markdown::Code {
                                my $file = %lookup{$val.text.lc};
                                if $file {
                                    $item.items[$idx] = "<a href=\"/docs/$file\">$val\</a>".subst('`', '', :g);
                                }
                            }
                        }
                    }
                    elsif $item ~~ Text::Markdown::Heading {
                        my $level = $item.level;
                        if $level > 1 {
                            my $anchor = $item.text.subst(' ', '_', :g);
                            if $level == 2 {
                                push @heading-links, q:c[<a href="#{$anchor}">{$item.text}</a>];
                            }
                            $item = wrap-header($item, $anchor);
                        }
                    }
                }
                my $content-html = $parsed.to_html;
                my $index-html = @heading-links
                    ?? q[<div class="docs-index"><strong>Contents</strong><ul>] ~
                        @heading-links.map({ q:c[<li>{$_}</li>] }).join("\n") ~
                        q[</ul></div>]
                    !! "";
                content 'text/html', $docs-template
                    .subst('<!--DOC-INDEX-->', $index-html)
                    .subst('<!--DOC-CONTENT-->', $content-html);
            }
            else {
                not-found;
            }
        }
    }
}
