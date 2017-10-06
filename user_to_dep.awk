#! /bin/sh
# this code is help &  contributed by Paul Pendent

S_BASE="ou=people,o=xyz.com"

AWK_LDAP='''
BEGIN {
    #.. Treat all likely punctuation as equivalent field separators.
    FS = "[:=, ]+";
    #.. RegExp to clip AttrName, but not split remaining words.
    reClip = "^[^:]*:[ ]*";
    #.. Format for output.
    fmt = "%-50s : %10s\n";
    #.. Make a separator string, same length as fmt.
    hSep = sprintf ("%63s", " "); gsub (".", "=", hSep);
}
NR == 1 { print hSep; printf (fmt, "        Name", "Department"); print hSep; }
$1 == "dn" && $2 == "uid" { Uid = $3; next; }
$1 == "kdsBusinessUnit" { sub (reClip, ""); printf (fmt, Uid, $0); } END { print hSep; }
'''
ldapsearch -h ldapserver1 -x -LLL -b "${S_BASE}" uid="*" kdsBusinessUnit | awk "${AWK_LDAP}"
