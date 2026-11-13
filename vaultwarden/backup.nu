#!/usr/bin/env nu

const keep = 30
const extras = [rsa_key.pem rsa_key.pub.pem config.json attachments sends]

# Vaultwarden keeps recent writes in db.sqlite3-wal, so the files can't simply be copied;
# VACUUM INTO produces a consistent single-file snapshot while the server keeps running.
const snapshot_py = r#'
import sqlite3, sys
sqlite3.connect(sys.argv[1]).execute("VACUUM INTO ?", (sys.argv[2],))
db = sqlite3.connect(sys.argv[2])
print(db.execute("PRAGMA integrity_check").fetchone()[0])
print(db.execute("SELECT count(*) FROM ciphers").fetchone()[0])
'#

def snapshot-db [src: path, dst: path]: nothing -> int {
    if not ($src | path exists) { error make {msg: $"missing database: ($src)"} }
    let report = ^python3 -c $snapshot_py $src $dst | lines
    if $report.0 != "ok" { error make {msg: $"snapshot failed integrity check: ($report.0)"} }
    $report.1 | into int
}

def snapshot [data: path, out: path]: nothing -> int {
    mkdir $out
    let ciphers = snapshot-db ($data | path join db.sqlite3) ($out | path join db.sqlite3)
    for p in ($extras | each {|name| $data | path join $name } | where {|p| $p | path exists }) {
        cp -r $p $out
    }
    $ciphers
}

def prune [dest: path] {
    for old in (glob ($dest | path join "vaultwarden-*.tar.zst") | sort --reverse | skip $keep) {
        rm $old
    }
}

def main [] {
    let data = $env.HOME | path join Vaultwarden data
    let dest = $env.HOME | path join Vault Backups Vaultwarden
    # Staged on the same filesystem as the Syncthing folder so the final mv is an atomic
    # rename and Syncthing never picks up a half-written archive.
    let staging = $env.HOME | path join .cache vaultwarden-backup
    let archive = $dest | path join $"vaultwarden-(date now | format date '%Y-%m-%dT%H%M%S').tar.zst"

    rm -rf $staging
    mkdir $staging $dest
    ^chmod 700 $dest

    let ciphers = snapshot $data ($staging | path join data)
    let staged = $staging | path join archive.tar.zst
    ^tar --zstd -cf $staged -C $staging data
    ^chmod 600 $staged
    mv $staged $archive
    rm -r $staging

    prune $dest
    print $"backed up ($ciphers) ciphers to ($archive)"
}
