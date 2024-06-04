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