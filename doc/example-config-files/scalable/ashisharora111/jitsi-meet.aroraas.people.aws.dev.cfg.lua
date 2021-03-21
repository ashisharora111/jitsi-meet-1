plugin_paths = { "/usr/share/jitsi-meet/prosody-plugins/" }

-- domain mapper options, must at least have domain base set to use the mapper
muc_mapper_domain_base = "jitsi-meet.aroraas.people.aws.dev";

turncredentials_secret = "turncredentials_secret_test";

turncredentials = {
    { type = "stun", host = "jitsi-meet.aroraas.people.aws.dev", port = "443" },
    { type = "turn", host = "jitsi-meet.aroraas.people.aws.dev", port = "443", transport = "udp" },
    { type = "turns", host = "jitsi-meet.aroraas.people.aws.dev", port = "443", transport = "tcp" }
};

cross_domain_bosh = false;
consider_bosh_secure = true;

VirtualHost "jitsi-meet.aroraas.people.aws.dev"
    -- enabled = false -- Remove this line to enable this host
    authentication = "anonymous"
    -- Properties below are modified by jitsi-meet-tokens package config
    -- and authentication above is switched to "token"
    --app_id="example_app_id"
    --app_secret="example_app_secret"
    -- Assign this host a certificate for TLS, otherwise it would use the one
    -- set in the global section (if any).
    -- Note that old-style SSL on port 5223 only supports one certificate, and will always
    -- use the global one.
    ssl = {
        key = "/etc/prosody/certs/jitsi-meet.aroraas.people.aws.dev.key";
        certificate = "/etc/prosody/certs/jitsi-meet.aroraas.people.aws.dev.crt";
    }
    speakerstats_component = "speakerstats.jitsi-meet.aroraas.people.aws.dev"
    conference_duration_component = "conferenceduration.jitsi-meet.aroraas.people.aws.dev"
    -- we need bosh
    modules_enabled = {
        "bosh";
        "pubsub";
        "ping"; -- Enable mod_ping
        "speakerstats";
        "turncredentials";
        "conference_duration";
    }
    c2s_require_encryption = false

Component "conference.jitsi-meet.aroraas.people.aws.dev" "muc"
    storage = "memory"
    modules_enabled = {
        "muc_meeting_id";
        "muc_domain_mapper";
        --"token_verification";
    }
    admins = { "focus@auth.jitsi-meet.aroraas.people.aws.dev" }
    muc_room_locking = false
    muc_room_default_public_jids = true

-- internal muc component
-- Note: This is also used from jibris
Component "internal.auth.jitsi-meet.aroraas.people.aws.dev" "muc"
    storage = "memory"
    modules_enabled = {
        "ping";
    }
    admins = { "focus@auth.jitsi-meet.aroraas.people.aws.dev", "jvb@auth.jitsi-meet.aroraas.people.aws.dev" }

VirtualHost "auth.jitsi-meet.aroraas.people.aws.dev"
    ssl = {
        key = "/etc/prosody/certs/auth.jitsi-meet.aroraas.people.aws.dev.key";
        certificate = "/etc/prosody/certs/auth.jitsi-meet.aroraas.people.aws.dev.crt";
    }
    authentication = "internal_hashed"

Component "focus.jitsi-meet.aroraas.people.aws.dev"
    component_secret = "jitsi-lab"

Component "speakerstats.jitsi-meet.aroraas.people.aws.dev" "speakerstats_component"
    muc_component = "conference.jitsi-meet.aroraas.people.aws.dev"

Component "conferenceduration.jitsi-meet.aroraas.people.aws.dev" "conference_duration_component"
    muc_component = "conference.jitsi-meet.aroraas.people.aws.dev"

-- for Jibri
VirtualHost "recorder.jitsi-meet.aroraas.people.aws.dev"
    modules_enabled = {
        "ping";
    }
    authentication = "internal_hashed"
    c2s_require_encryption = false
