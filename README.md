Triangles (TRI) "Black Pharao" Version 4.2.1.0 Release, 

Triangles is a cool new crypto currency that features TOR implementation and secure messaging.

This wallet supports the staking=0 option in the triangles.conf file to disable the stake miner thread for pool and exchange operators.

## Tor v3 support

Version 4.2.1.1 (protocol 70205) adds first-class support for Tor v3 onion services. Nodes now
preserve the full 56 character onion hostname when exchanging addresses so they can establish
SOCKS5 connections through a Tor proxy without falling back to deprecated v2 services.

### Preparing seed nodes

1. Deploy Tor 0.4.7.x or newer on each seed machine.
2. Create a v3 hidden service in `torrc` (or `torrc.d/*.conf`) with:
   ```
   HiddenServiceDir /var/lib/tor/triangles
   HiddenServiceVersion 3
   HiddenServicePort 19099 127.0.0.1:24112
   ```
   Restart Tor and note the generated 56 character hostname in
   `/var/lib/tor/triangles/hostname`.
3. Update `src/onionseed.h` with the published v3 hostnames so that fresh wallets can bootstrap
   over Tor without relying on DNS or clearnet peers.
4. Commit and redeploy the updated seed list, or distribute the hostnames to trusted operators so
   they can add them manually via `triangles.conf`.

### Upgrading wallet nodes

1. Install Tor >= 0.4.7 locally and configure a v3 hidden service as described above. The bundled
   Tor instance will detect the hostname in the data directory (`$DATADIR/onion/hostname`).
2. Build and install the wallet:
   ```
   qmake triangles-qt.pro
   make
   ```
3. Ensure your `triangles.conf` contains the Tor proxy settings:
   ```
   proxy=127.0.0.1:9050
   tor=127.0.0.1:9050
   listen=1
   staking=1
   ```
4. Start the wallet. It will register its v3 onion address automatically, seed from the v3 peers,
   and advertise its hidden service to the rest of the network.

With all peers upgraded to protocol 70205 or newer the network can operate entirely over Tor v3
hidden services, avoiding the hard deprecation of Tor v2 onions.

## Draft will helper script (Windows)

For operators who want to prepare personal documentation alongside their node backups, the
repository now includes a small PowerShell helper located at `contrib/will-template.ps1`. The script
walks through common questions that appear in a simple last will and testament and writes the
answers to a draft text file you can review with your legal counsel.

### Running the script

1. Open **PowerShell** on your Windows machine. If your execution policy blocks local scripts,
   run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` first.
2. Clone or copy this repository so the script is available locally.
3. From the repository root, execute:
   ```powershell
   cd .\contrib
   .\will-template.ps1 -OutputPath C:\\Users\\$env:USERNAME\\Documents\\draft-will.txt
   ```
4. Answer the prompts. When finished, the draft will be saved to the path you supplied.
5. Review the generated document with a licensed attorney to ensure it meets the legal
   requirements of your jurisdiction before relying on it.

