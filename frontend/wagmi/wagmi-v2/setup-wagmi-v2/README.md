# Setup Wagmi v2 for React + Vite + TS project

## Step 1
Create `config.ts` file in project root directory
```
.
├── config.ts
├── index.html
├── node_modules
├── package.json
├── pnpm-lock.yaml
├── public
├── README.md
├── src
├── tsconfig.json
├── tsconfig.node.json
├── vite.config.ts
└── yarn.lock
```
Add this code snippet (/frontend/wagmi/wagmi-v2/setup-wagmi-v2/react-vite-ts/config.ts) to `config.ts`.
```tsx
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
```


## Step 2
Wrap your `App` component in `App.tsx` file with the below code snippet

```tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query' 
import { WagmiProvider } from 'wagmi'
import { config } from './config'

const queryClient = new QueryClient() 

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}> 
        {/** ... */} 
      </QueryClientProvider> 
    </WagmiProvider>
  )
}
```

## Resources
- [`config.ts`](/frontend/wagmi/wagmi-v2/setup-wagmi-v2/react-vite-ts/config.ts)
- [`App.tsx`](/frontend/wagmi/wagmi-v2/setup-wagmi-v2/react-vite-ts/App.tsx)