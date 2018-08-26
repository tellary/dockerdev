#!/usr/bin/perl

if (scalar(@ARGV) == 0) {
    print "Usage get-maven-source GAV [REPO_PREFIX]\n";
    exit 1;
}

$gav = $ARGV[0];
$repo_prefix = "https://search.maven.org/remotecontent?filepath=";
if (scalar(@ARGV > 1)) {
    $repo_prefix = $ARGV[1];
}

$gav =~ /([^:]+):([^:]+):([^:]+)/;
$g = $1;
$a = $2;
$v = $3;
$g =~ s|\.|/|g;
$path = "$g/$a/$v/$a-$v-sources.jar";
$url = $repo_prefix . $path;
$jar = "$a-$v-sources.jar";
$dir = "$a-$v";
!system("mkdir $dir") or die "Unable to create directory: $dir";
print "curl -L -o $jar $url\n";
if (system("curl -L -o $jar $url")) {
    `rm -rf $dir`;
    `rm $jar`;
    die "Unable to get source jar: $url";
}
`mv $jar $dir/`;
chdir $dir;
$error_str = `jar tf b-c-sources.jar 2>&1 | grep java.util.zip.ZipException:`;
if (length($error_str) > 0) {
    chdir "..";
    `rm -rf $dir`;
    die "Unable to open downloaded jar file: $url";
}
`jar xf $jar`;
`rm $jar`;
`find -name '*.java' | ctags -e -L -`
