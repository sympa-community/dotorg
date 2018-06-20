FROM debian:buster
RUN set -eu ;\
    : TODO: proxyport should be a buildarg ;\
    : TODO: but i failed to use it;\
    proxyport=3142 ;\
    test $proxyport && { ip route |\
        awk -vport=$proxyport -vaddr=3 -vfmt='Acquire::http::Proxy "http://%s:%s";' \
            '/^default via / { printf fmt, $addr, port }' \
        > /etc/apt/apt.conf.d/00Proxy; \
    };\
    apt update  -y ;\
    apt install -y curl gpg ;\
    curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key |\
        apt-key add - &\
    echo deb https://deb.nodesource.com/node_10.x buster main >\
        /etc/apt/sources.list.d/nodesource.sources.list ;\
    wait ;\
    apt update  -y ;\
    apt install -y nodejs ;\
    npm install -g pug-cli stylus & {\
        apt upgrade -y ;\
        apt install -y\
            zsh\
            pandoc\
            9base\
            m4 ;\
        rm -rf /var/lib/apt/lists/* ;\
    };\
    wait

WORKDIR /code
