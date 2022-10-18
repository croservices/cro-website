my $deployment = slurp('deployment.yaml');
with $deployment ~~ /':v'(\d+)/ -> (Int() $version is copy) {
    $version++;
    my $tag = "gcr.io/mystical-banner-176722/app:v$version";
    run 'docker', 'build', '-t', $tag, '.';
    run 'gcloud', 'docker', '--', 'push', $tag;
    $deployment ~~ s/':v'(\d+)/:v$version/;
    spurt 'deployment.yaml', $deployment;
    run 'kubectl', 'apply', '-f', 'deployment.yaml';
}
else {
    die "Could not find version in deployment.yaml";
}
