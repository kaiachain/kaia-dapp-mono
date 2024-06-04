import { createWeb3Modal } from '@web3modal/wagmi/react'

import { http, createConfig, WagmiProvider } from 'wagmi'
import { klaytn, klaytnBaobab } from 'wagmi/chains'
import { walletConnect, injected, coinbaseWallet } from 'wagmi/connectors'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

// 0. Setup queryClient
const queryClient = new QueryClient()

// 1. Get projectId at https://cloud.walletconnect.com
const projectId = 'YOUR_PROJECT_ID'

// 2. Create WallectConnect config
const metadata = {
  name: 'Web3Modal', // add name of your DApp
  description: 'Web3Modal Example', // add description of your DApp
  url: 'https://web3modal.com', // origin must match your domain & subdomain
  icons: ['https://avatars.githubusercontent.com/u/37784886']
}

// Create wagmiConfig
const config = createConfig({
  chains: [ klaytn, klaytnBaobab ],
  transports: {
    [klaytn.id]: http("https://rpc.ankr.com/klaytn"), // you can replace the http() with any other RPC URL you like
    [klaytnBaobab.id]: http("https://rpc.ankr.com/klaytn_testnet") // you can replace the http() with any other RPC URL you like
  },
  connectors: [
    walletConnect({ projectId, metadata, showQrModal: false }),
    injected({ shimDisconnect: true }),
  ]
})

// 3. Create Web3Modal
createWeb3Modal({
  wagmiConfig: config,
  projectId,
  enableAnalytics: false, // Optional - defaults to your Cloud configuration
  defaultChain: klaytn, klaytnBaobab,
  chainImages: {
    8217: '/Klaytn_Symbol.png',
    1001: '/Klaytn_Symbol.png'
  }
})


export function Web3Modal({ children }) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    </WagmiProvider>
  )
}