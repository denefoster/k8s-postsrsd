postsrsd
==========================

[Postfix Sender Rewriting Scheme daemon](https://github.com/roehling/postsrsd)

If using the milter interface add the following to your postfix config:

```
-o smtpd_milters=inet:$POSTSRSD_HOST:9997
```

To any interface you want in main.conf, probably the ```smtp``` line.


Or to use the old, inet socket by adding the following to main.cf:

```
sender_canonical_maps = socketmap:unix:srs:forward
sender_canonical_classes = envelope_sender
recipient_canonical_maps = socketmap:unix:srs:reverse
recipient_canonical_classes = envelope_recipient, header_recipient
```

### Usage

 `docker run --rm --name postfix-postsrsd -e  SRS_DOMAIN=domaintouse.org -e "SRS_SECRET=k/bWL9OyMBGTJ9p4Hb1owcag" ghcr.io/denefoster/postsrsd`

### Environment

- `SRS_DOMAIN`: Domain to use for sender rewriting (mandatory)
- `SRS_SECRET`: Secret used to hash the sender email. Generate one with this command: `dd if=/dev/random bs=18 count=1 | base64` (mandatory)
- `SRS_EXCLUDE_DOMAINS`: Senders in these domains will not be rewritten (optional)
- `SRS_SEPARATOR`: Separator used when rewriting the sender email, default is "=" which generates a rewritten address like this: `SRS0+xxxx=yy=example.com=alice@yourdomain.org` (optional)
- `SRS_SOCKET_PORT`: Port used for socketmap SRS, default is 10003 (optional)
- `SRS_HASHLENGTH`: Hash length used when rewriting the sender, default is 4 (optional)
- `SRS_HASHMIN`: Minimum hash length to consider when doing reverse SRS, default is 4 and should match `SRS_HASHLENGTH` (optional)
- `RUN_AS`: User to run the daemon as, default is postsrsd (optional)
- `CHROOT`: Directory to use for chroot, default is /var/lib/postsrsdr (optional)
- `SRS_LISTEN_ADDRESS`: Default is 0.0.0.0 (optional)
- `MILTER_LISTEN_ADDRESS`: Default is 0.0.0.0 (optional)
- `OG_ENVELOPE`: defaults to embedded (optional)
- `REDIS_HOST`: defaults to postsrsd-valkey (optional)


#### Secret

> Be careful that no one can guess your secret, because anyone who knows it can use your mail server as an open relay!
