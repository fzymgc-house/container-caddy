FROM caddy:2-builder-alpine@sha256:cc6c40aa7cdea02ef9cb99f3c4e4664ecdb6066ae93ae52ed5288afc511e1241 AS builder

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

FROM caddy:2-alpine@sha256:ae4458638da8e1a91aafffb231c5f8778e964bca650c8a8cb23a7e8ac557aa3c

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY --from=builder /tmp/geoip /usr/share/caddy/geoip
