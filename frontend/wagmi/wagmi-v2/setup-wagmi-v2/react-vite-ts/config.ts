import { http, createConfig } from 'wagmi'
import { klaytn, klaytnBaobab } from 'wagmi/chains'

// Create wagmiConfig
export const config = createConfig({
  chains: [ klaytn, klaytnBaobab ],
  transports: {
    [klaytn.id]: http("https://rpc.ankr.com/klaytn"), // you can replace the http() with any other RPC URL you like
    [klaytnBaobab.id]: http("https://rpc.ankr.com/klaytn_testnet") // you can replace the http() with any other RPC URL you like
  },
})
