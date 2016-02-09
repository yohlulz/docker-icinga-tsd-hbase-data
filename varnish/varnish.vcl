# VCL configuration for OpenTSDB.

backend ro_1 {
    .host = "tsd_tsdb_ro_1";
    .port = "4242";
    .probe = {
        .url = "/version";
        .interval = 30s;
        .timeout = 10s;
        .window = 5;
        .threshold = 3;
    }
}


backend ro_2 {
    .host = "tsd_tsdb_ro_2";
    .port = "4242";
    .probe = {
        .url = "/version";
        .interval = 30s;
        .timeout = 10s;
        .window = 5;
        .threshold = 3;
    }
}


backend ro_3 {
    .host = "tsd_tsdb_ro_3";
    .port = "4242";
    .probe = {
        .url = "/version";
        .interval = 30s;
        .timeout = 10s;
        .window = 5;
        .threshold = 3;
    }
}

# The `client' director will select a backend based on `client.identity'.
# It's normally used to implement session stickiness but here we abuse it
# to try to send pairs of requests to the same TSD, in order to achieve a
# higher cache hit rate.  The UI sends queries first with a "&json" at the
# end, in order to get meta-data back about the results, and then it sends
# the same query again with "&png".  If the second query goes to a different
# TSD, then that TSD will have to fetch the data from HBase again.  Whereas
# if it goes to the same TSD that served the "&json" query, it'll hit the
# cache of that TSD and produce the PNG directly without using HBase.
#
# Note that we cannot use the `hash' director here, because otherwise Varnish
# would hash both the "&json" and the "&png" requests identically, and it
# would thus serve a cached JSON response to a "&png" request.
director tsd client {
    { .backend = ro_1; .weight = 100; }
    { .backend = ro_2; .weight = 100; }
    { .backend = ro_3; .weight = 100; }
}

sub vcl_recv {
    set req.backend = tsd;
    # Make sure we hit the same backend based on the URL requested,
    # but ignore some parameters before hashing the URL.
    set client.identity = regsuball(req.url, "&(o|ignore|png|json|html|y2?range|y2?label|y2?log|key|nokey)\b(=[^&]*)?", "");
}

sub vcl_hash {
    # Remove the `ignore' parameter from the URL we hash, so that two
    # identical requests modulo that parameter will hit Varnish's cache.
    hash_data(regsuball(req.url, "&ignore\b(=[^&]*)?", ""));
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    return (hash);
}

