FROM caddy:2-builder-alpine@sha256:0ff10d4b83af453e5526b1c3cd7ae43396832aa8a2a55311d624f6812b33767d AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/hslatman/caddy-crowdsec-bouncer/http \
    --with github.com/greenpau/caddy-security \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/mholt/caddy-ratelimit \
    --with github.com/porech/caddy-maxmind-geolocation \
    --output /usr/bin/caddy

# Download GeoIP database (replace YOUR_LICENSE_KEY)
ARG MAXMIND_LICENSE_KEY
RUN if [ -n "$MAXMIND_LICENSE_KEY" ]; then \
    wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${MAXMIND_LICENSE_KEY}&suffix=tar.gz" -O /tmp/GeoLite2-Country.tar.gz && \
    tar -xzf /tmp/GeoLite2-Country.tar.gz -C /tmp && \
    mkdir -p /tmp/geoip && \
    cp /tmp/GeoLite2-Country_*/GeoLite2-Country.mmdb /tmp/geoip/; \
    fi

FROM caddy:2-alpine@sha256:77c07d5ebfa5be9fd6c820d2094ae662c9e7eeb9bf98346b7f639900263ee2a2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /tmp/geoip /usr/share/caddy/geoip
