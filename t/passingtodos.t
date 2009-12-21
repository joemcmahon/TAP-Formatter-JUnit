use Test::More tests=>2;
use Test::Differences;
use File::Temp qw(tempfile);
use File::Slurp;
use FindBin;

my $tap = <<EOF;
1..3
ok 1
ok 2 # TODO Shouldn't pass yet
ok 3
EOF

my $fail_if_passing = <<EOF;
<testsuites>
  <testsuite failures="0" errors="1" tests="3" name="fail">
    <testcase name="1"></testcase>
    <testcase name="2">
      <error type="TodoTestSucceeded"
             message="Shouldn't pass yet"><![CDATA[ok 2 # TODO Shouldn't pass yet]]></error>
    </testcase>
    <testcase name="3"></testcase>
    <system-out><![CDATA[1..3
ok 1
ok 2 # TODO Shouldn't pass yet
ok 3
]]></system-out>
    <system-err></system-err>
  </testsuite>
</testsuites>
EOF
chomp $fail_if_passing;

my $success_if_passing = <<EOF;
<testsuites>
  <testsuite failures="0" errors="0" tests="3" name="succeed">
    <testcase name="1"></testcase>
    <testcase name="2"></testcase>
    <testcase name="3"></testcase>
    <system-out><![CDATA[1..3
ok 1
ok 2 # TODO Shouldn't pass yet
ok 3
]]></system-out>
    <system-err></system-err>
  </testsuite>
</testsuites>
EOF
chomp $success_if_passing;

my($fh, $file) = tempfile();
print $fh $tap;
close $fh;

$pass_them = `ALLOW_PASSING_TODOS=1 $^X -Iblib/lib $FindBin::Bin/../bin/tap2junit --junit succeed - <$file`;
$fail_them   = `$^X -Iblib/lib $FindBin::Bin/../bin/tap2junit --junit fail - <$file`;

eq_or_diff $pass_them, $success_if_passing, 'can make them pass';
eq_or_diff $fail_them, $fail_if_passing,    'fail by default';
