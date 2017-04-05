#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

my $class = "Metal::Handler::Creator";
my $creator;

use_ok($class) || BAIL_OUT("Cannot load class");

# First test class
ok($creator = Metal::Handler::Creator->new({
    name => 'First::Test',
    type => 'TestCase',
}), "Builder 1 ran");

is($creator->filename, 'lib/Metal/Handler/First/Test.pm',
    "Filename 1 is accurate 1",
);

isnt($creator->filename, 'First::Test',
    "Filename 1 is accurate 2",
);

is($creator->type_block, "\n\nsub _build_type { 'TestCase' }",
    "Type block 1 is accurate",
);

like($creator->template, qr/^package Metal::Handler::First::Test;/,
    "Template 1 package line looks right",
);

# Second test class
ok($creator = Metal::Handler::Creator->new({
    name => 'Second::Test',
}), "Builder 2 ran");

is($creator->filename, 'lib/Metal/Handler/Second/Test.pm',
    "Filename 2 is accurate 1",
);

isnt($creator->filename, 'Second::Test',
    "Filename 2 is accurate 2",
);

is($creator->type_block, '',
    "Type block 2 is accurate",
);

like($creator->template, qr/^package Metal::Handler::Second::Test;/,
    "Template 2 package line looks right",
);

done_testing();
__END__

=head1 NAME

t/20-units/Handler/Creator.t

=head1 DESCRIPTION

Test cases for Handler creation module.

=head1 AUTHOR

Mike Jones L<email:mike@netsplit.org.uk>

