tshark_fields = [
    "-T", "fields",
    "-e", "ip.src", "-e", "ip.dst",
    "-e", "tcp.srcport", "-e", "tcp.dstport",
    "-e", "udp.srcport", "-e", "udp.dstport",
    "-e", "frame.len", "-e", "frame.time_relative",
    "-e", "frame.protocols",
    "-e", "tcp.payload", "-e", "udp.payload", "-e", "data.data",
    "-E", "separator=|", "-E", "quote=d", "-E", "header=y"
]

cmd = [
    "tshark", "-r", str(pcap_file),
    "-Y", "ip && (tcp || udp)",
    "--disable-protocol", "cldap", "--disable-protocol", "ldap"
] + tshark_fields