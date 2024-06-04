interface Error {
  code: number
  message: string
  stack: string
}

export default function AddNetworkButton() {

  async function addKlaytnBaobabNetwork() {
    try {
      await window.ethereum.request({
        "method": "wallet_addEthereumChain",
        "params": [
          {
            "blockExplorerUrls": [
              "https://baobab.klaytnfinder.io/"
            ],
            "iconUrls": [
              "https://klaytn.foundation/wp-content/themes/klaytn/download/klaytn-symbol.png"
            ],
            "nativeCurrency": {
              "name": "KLAY",
              "symbol": "KLAY",
              "decimals": 18
            },
            "rpcUrls": [
              "https://rpc.ankr.com/klaytn_testnet"
            ],
            "chainId": "0x3e9",
            "chainName": "Klaytn Testnet Baobab"
          }
        ]
      });
      await window.ethereum.request({
        "method": "wallet_switchEthereumChain",
        "params": [
          {
            "chainId": "0x3e9"
          }
        ]
      });
    } catch (error) {
      // This error code indicates that the chain has not been added to MetaMask.
      if ((error as Error).code === 4001) {
        alert({
          message: "User rejected to add network to Metamask",
          duration: 3000,
        })
      }
      // handle other "switch" errors
    }
  }

  async function addKlaytnNetwork() {
    try {
      await window.ethereum.request({
        "method": "wallet_addEthereumChain",
        "params": [
          {
            "blockExplorerUrls": [
              "https://klaytnfinder.io/"
            ],
            "iconUrls": [
              "https://klaytn.foundation/wp-content/themes/klaytn/download/klaytn-symbol.png"
            ],
            "nativeCurrency": {
              "name": "KLAY",
              "symbol": "KLAY",
              "decimals": 18
            },
            "rpcUrls": [
              "https://rpc.ankr.com/klaytn"
            ],
            "chainId": "0x2019",
            "chainName": "Klaytn Mainnet Cypress"
          }
        ]
      });
      await window.ethereum.request({
        "method": "wallet_switchEthereumChain",
        "params": [
          {
            "chainId": "0x2019"
          }
        ]
      });
    } catch (error) {
      // This error code indicates that the chain has not been added to MetaMask.
      if ((error as Error).code === 4001) {
        alert({
          message: "User rejected to add network to Metamask",
          duration: 3000,
        })
      }
      // handle other "switch" errors
    }
  }

  return (
    <button onClick={() => addKlaytnBaobabNetwork()}>
      Add network to Metamask
    </button>
    <button onClick={() => addKlaytnNetwork()}>
      Add network to Metamask
    </button>
  )
}
