use Cro::HTTP::Router;
use Cro::WebApp::Template;
use Text::Markdown;

sub routes() is export {
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

    template-location 'templates';

    route {
        get -> {
            template 'index.crotmp';
        }
        get -> 'training-support' {
            template 'support.crotmp';
        }
        get -> 'roadmap' {
            template 'roadmap.crotmp';
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
        get -> 'favicon.ico' {
            static 'static-content/favicon.ico'
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
            "<a name=\"$anchor\">" ~ '<h' ~ $h.level ~
                ' style="padding-top: 150px; margin-top: -150px;">' ~ $h.text ~
                "<a class=\"title-anchor\" href=\"#$anchor\">§</a>" ~
                '</h' ~ $h.level ~ '></a>';
        }

        sub link-code($item) {
            for $item.items.kv -> $idx, $val {
                when $val ~~ Text::Markdown::Code {
                    my $file = %lookup{$val.text.lc};
                    if $file {
                        $item.items[$idx] = "<a href=\"/docs/$file\">$val\</a>".subst('`', '', :g);
                    }
                }
            }
        }

        sub doc-markdown($path) {
            with slurp("docs/$path") -> $markdown {
                my $parsed = parse-markdown($markdown);
                my $title = 'documentation';
                my @heading-links;
                for $parsed.document.items -> $item is rw {
                    if $item ~~ Text::Markdown::Paragraph {
                        link-code($item);
                    }
                    elsif $item ~~ Text::Markdown::List {
                        for $item.items -> $list-item {
                            for $list-item.items -> $val {
                                if $val ~~ Text::Markdown::Paragraph {
                                    link-code($val);
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
                        else {
                            $title = $item.text;
                        }
                    }
                }
                my $body = $parsed.to_html;
                my $index = @heading-links
                    ?? q[<div class="docs-index"><strong>Contents</strong><ul>] ~
                        @heading-links.map({ q:c[<li>{$_}</li>] }).join("\n") ~
                        q[</ul></div>]
                    !! "";
                template 'docs.crotmp', %( :$title, :$body, :$index );
            }
            else {
                not-found;
            }
        }
    }
}
