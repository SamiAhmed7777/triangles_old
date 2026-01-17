# Triangles Cryptocurrency Restart Notes

This document contains critical information for restarting the Triangles (TRI) cryptocurrency network.

## 1. Network Status
The network has been inactive for several years. The original peers and seed nodes are likely offline. The "Synchronized Checkpoint" system, which relies on a central authority to sign checkpoints, prevents the chain from moving forward without the corresponding private key.

## 2. Checkpoint Master Key
To enable the network to restart and accept new checkpoints, you must generate a **new Checkpoint Master Key pair** and update the code (`src/checkpoints.cpp`).

**Security Warning**: The Private Key must be kept SECRET and OFFLINE. Do not commit it to the repository.

### How to Generate a New Key Pair
You need `openssl` installed. Run the following commands:

```bash
# Generate a new private key
openssl ecparam -name secp256k1 -genkey -out checkpoint_priv.pem

# Extract the Public Key (in hex format)
# This will output a hex string starting with 04...
openssl ec -in checkpoint_priv.pem -pubout -outform DER | tail -c 65 | xxd -p -c 65
```

### Update the Code
1.  Copy the **Public Key** hex string generated above.
2.  Open `src/checkpoints.cpp`.
3.  Find the line:
    ```cpp
    const std::string CSyncCheckpoint::strMasterPubKey = "...";
    ```
4.  Replace the string value with your new Public Key.

### Safe Storage
Store `checkpoint_priv.pem` in a secure location (e.g., an encrypted USB drive). You will need this key to sign checkpoints using the `sendcheckpoint` RPC command or a custom tool.

## 3. Network Bootstrap (Seeds & Tor)
### Tor Bundling
The repository now includes a script to download and build a static **Tor** binary (v0.4.8.x or later) which supports modern Tor v3 onion services.

**The build system automatically compiles and bundles Tor.** You do **NOT** need to install Tor separately, although `trianglesd` can still use a system Tor if configured with `-proxy`.

When `trianglesd` starts, it will:
1.  Check for the `tor_embedded` binary.
2.  Launch it in the background.
3.  Create a `torrc` in `<datadir>/tor/torrc` if missing.
4.  Create a hidden service in `<datadir>/onion/service`.

### How to Configure Tor v3
1.  Start the wallet/daemon: `./trianglesd -daemon`.
2.  Wait for it to start Tor.
3.  Get your onion address:
    ```bash
    cat ~/.triangles/onion/service/hostname
    ```
4.  **Important**: The wallet needs to know its own onion address to advertise it. The updated code attempts to read this automatically.

### Updating Seed Nodes
1.  Run a stable node as above.
2.  Get the onion address.
3.  Update `src/onionseed.h` with this address.
4.  Recompile and distribute the wallet/daemon.

## 4. Compilation & Dependencies
The codebase uses older C++ standards and libraries (Boost, OpenSSL 1.x, Berkeley DB 4.8).

**Requirements:**
*   **OS**: Recommended to use an older Linux distribution (e.g., Ubuntu 14.04 or 16.04) or a container to avoid compatibility hell with OpenSSL 3.0 and new Boost versions.
*   **Libraries**:
    *   `libboost-all-dev`
    *   `libssl-dev` (OpenSSL 1.0.x preferred)
    *   `libdb4.8-dev` and `libdb4.8++-dev` (Bitcoin PPA often has these)
    *   `libevent-dev`
    *   `libminiupnpc-dev` (optional)
    *   `wget` (for downloading Tor)

**Build Instructions:**
1.  `cd src`
2.  `make -f makefile.unix`

This will automatically download and build Tor, then build `trianglesd`.

### Docker Build (Recommended)
To avoid dependency issues (especially with newer OpenSSL or BDB versions), you can use the provided `Dockerfile`.

1.  Build the image:
    ```bash
    docker build -t triangles-node .
    ```
2.  Run the node:
    ```bash
    docker run -v $(pwd)/data:/root/.triangles triangles-node
    ```

## 5. Difficulty & Staking
Since the chain has been stuck, the difficulty might be high relative to the current hash power (staking power).
*   **PoS**: Coin age accumulates. This effectively lowers the difficulty for finding a block. Old wallets with coins should easily mint a block once they connect.
*   **Hacks**: If the chain refuses to move, look at `src/kernel.cpp`. There is logic for `CRAPCHAIN_CUTOFF_BLOCK`. You might need to implement a similar bypass to accept any block for a short period to "jump start" the chain.

## 6. Next Steps
1.  **Set up environment**: Get a VM with Ubuntu 16.04 or 18.04.
2.  **Install deps**: `sudo apt-get install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev wget` + Berkeley DB 4.8.
3.  **Compile**: `cd src && make -f makefile.unix`.
4.  **Run**: `./trianglesd -daemon`.
5.  **Connect**: Since seeds are empty, you need to manually connect nodes using `addnode=<ip>` in `triangles.conf` until you update the source code with new onion seeds.
6.  **Stake**: Unlock a wallet with coins (`walletpassphrase "password" 9999999 true`) and wait for it to stake.

Good luck!
